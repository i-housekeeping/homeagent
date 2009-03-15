class CustomersController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  # GET /customers
  # GET /customers.xml
  def index(customer_type = params[:customer_type])
    
    logger.warn "Test"
    
    if(params[:source] == "FILE")
      fileName = params[:activation_key].empty? == false ? session[:company].customer_name : params[:customer_name]
      fileName+= "_#{params[:activation_key]}" if !params[:activation_key].empty?
      logger.warn fileName
      @customers ||= YAML::load(File.open("#{RAILS_ROOT}/db/shared/customers/#{fileName}.yml" ))
    else
      query = "customer_type like '%#{customer_type}'" 
      #query += " and customer_name like '#{params[:customer_name]}%'" if !params[:customer_name].nil?
      #query += " and city like '#{params[:customer_city]}%'" if !params[:customer_city].nil?
      #query += " and country like '#{params[:customer_country]}%'" if !params[:customer_country].nil?
      query += " and record_sts = 'ACTV'"
      
      fields = (params[:fields].nil? or params[:fields].empty? )? "*" : params[:fields]
      @customers ||= Customer.find(:all,:conditions=>query, :select=>fields)
    end
        
    if (@customers.size == 0)
      @customers << Customer.new
      @customers[0].customer_type = params[:customer_type]
      @customers[0][:authenticity_token] = form_authenticity_token
    else
      @customers.map{|cust| cust[:authenticity_token] = form_authenticity_token }
    end
    
    logger.warn "Test"
    
    
   customers_hash = Hash.new()
   customers_list = @customers.map {|customer| 
               customers_hash[customer.id] = 
                {
                :id => customer.id,
                :authenticity_token => customer.authenticity_token,
                :customer_name => customer.customer_name,
                :customer_type => customer.customer_type,
                :city => customer.city,
                :country => customer.country,
                :address => customer.address,
                :phone => customer.phone,
                :fax => customer.fax,
                :email => customer.email} }
    
   
      
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
      format.json { render :json => @customers}
      format.js { render :js => "#{params[:callback]}(#{customers_list.to_json()});" }
      format.chr { render :chr => customers_hash }
      format.jsonc { render :jsonc => customers_list }
    end
  end
  
  def comapanies_list
    comapanies ||= Customer.find(:all, :select=>"id, customer_name")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => comapanies.to_xml }
      format.json { render :json => comapanies.to_json}
    end
  end
  
  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end
  
  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end
  
  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
  end
  
  # POST /customers
  # POST /customers.xml
  def create
    set_customer_params params
    @customer = Customer.new(params[:customer])
    
    
    respond_to do |format|
      if @customer.save
        format.html { 
          render :text=>"{success:true,
                          notice:'Customer #{params[:customer][:s_company_name]} was successfully created.'}", :layout=>false
        }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:company_id])
    set_customer_params params
    
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html { 
          render :text=>"{success:true,
                          notice:'Customer #{params[:customer][:s_company_name]} was successfully updated.'}", :layout=>false
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:company_id])
    @customer.destroy
    
    respond_to do |format|
      format.html {  
        render :text=>"{success:true }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def comapanies_sharelist
    companies_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
    Dir.foreach("#{RAILS_ROOT}/db/shared/customers") { |x| companies_list.push({:company_name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => companies_list.to_xml }
      format.json { render :json => companies_list.to_json}
    end
  end
  
  def postdirectory
    customers = Customer.find(:all, :conditions=>"id in (#{params[:items_list]})")
    
    if(params[:share].eql? "true")
      #Posted on Bloney Cashflow site  everybody could see it
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
      File.open("#{RAILS_ROOT}/db/shared/customers/#{session[:company].customer_name}.yml", 'w') {|f| f.write(customers.to_yaml) }
    else
      #Posted on company site soe everybody could see it
      key = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{session[:company].customer_name}--")
      
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
      File.open("#{RAILS_ROOT}/db/shared/customers/#{session[:company].customer_name}_#{key}.yml", 'w') {|f| f.write(customers.to_yaml) }
      
      params[:from] = "admin@bloney.co.cc"
      params[:to_company] = Customer.find(:first,:conditions=>"customer_name='#{params[:expert_name]}'")[:email]
      params[:subject] = "Customers Directory"
      params[:email_editor] = "#{session[:company].customer_name} customers directory is available for your usage. Activation key is :#{key} "
      UserNotifier.deliver_customeremail(params)
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Customers directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
    logger.warn "  " + params[:items_list]
    customers = YAML::load(File.open("#{RAILS_ROOT}/db/shared/customers/#{params[:customer_name]}.yml" ))
    customers.each do |item| 
      if(params[:items_list].include? ",#{item.attributes["id"]},")
        item.setAdobted(params[:customer_name])
        Customer.create(item.attributes)
      end
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Customers directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
      FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml")
    end
    
    if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
      Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
      FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Customers directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def sendmail
    params[:from] = "admin@bloney.co.cc"
    UserNotifier.deliver_customeremail(params) 
    
    respond_to do |format|
      format.html {
        render :text=>"{success:true,
                        notice:'Mail sent sucessfully ' }", :layout=>false
      }
      format.xml  { head :ok }
    end
    
  end
  
  def set_customer_params (params)
    params[:customer] = {
      :customer_name=>params[:s_company_name],
      :customer_type=>params[:abbrId],
      :city=>params[:s_city],
      :country=>params[:s_country],
      :address=>params[:s_address],
      :phone=>params[:s_phone],
      :fax=>params[:s_fax],
      :email=>params[:s_email],
      :url=>params[:s_url]
    }
  end
end
