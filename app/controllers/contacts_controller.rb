class ContactsController < ApplicationController
 #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  # GET /customers
  # GET /customers.xml
  def index(customer_type = params[:contact_type])
    
    logger.warn "Test"
    
    if(params[:source] == "FILE")
      fileName = params[:activation_key].empty? == false ? session[:company].contact_name : params[:contact_name]
      fileName+= "_#{params[:activation_key]}" if !params[:activation_key].empty?
      logger.warn fileName
      @contacts ||= YAML::load(File.open("#{RAILS_ROOT}/db/shared/contacts/#{fileName}.yml" ))
    else
      query = "contact_type like '%#{contact_type}'" 
      #query += " and contact_name like '#{params[:contact_name]}%'" if !params[:contact_name].nil?
      #query += " and city like '#{params[:contact_city]}%'" if !params[:contact_city].nil?
      #query += " and country like '#{params[:contact_country]}%'" if !params[:contact_country].nil?
      query += " and record_sts = 'ACTV'"
      
      fields = (params[:fields].nil? or params[:fields].empty? )? "*" : params[:fields]
      @contacts ||= Contact.find(:all,:conditions=>query, :select=>fields)
    end
        
    if (@contacts.size == 0)
      @contacts << Contact.new
      @contacts[0].contact_type = params[:contact_type]
      @contacts[0][:authenticity_token] = form_authenticity_token
    else
      @contacts.map{|cust| cust[:authenticity_token] = form_authenticity_token }
    end
    
    logger.warn "Test"
    
    
   contacts_hash = Hash.new()
   contacts_list = @contacts.map {|contact| 
               contacts_hash[contact.id] = 
                {
                :id => contact.id,
                :authenticity_token => contact.authenticity_token,
                :contact_name => contact.contact_name,
                :contact_type => contact.contact_type,
                :city => contact.city,
                :country => contact.country,
                :address => contact.address,
                :phone => contact.phone,
                :fax => contact.fax,
                :email => contact.email} }
    
   
      
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
      format.json { render :json => @contacts}
      format.js { render :js => "#{params[:callback]}(#{contacts_list.to_json()});" }
      format.chr { render :chr => contacts_hash }
      format.jsonc { render :jsonc => contacts_list }
    end
  end
  
  def comapanies_list
    comapanies ||= Contact.find(:all, :select=>"id, contact_name")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => comapanies.to_xml }
      format.json { render :json => comapanies.to_json}
    end
  end
  
  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = Contact.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end
  
  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Contact.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end
  
  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end
  
  # POST /contacts
  # POST /contacts.xml
  def create
    set_contact_params params
    @contact = Contact.new(params[:contact])
    
    
    respond_to do |format|
      if @contact.save
        format.html { 
          render :text=>"{success:true,
                          notice:'Contact #{params[:contact][:s_company_name]} was successfully created.'}", :layout=>false
        }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:company_id])
    set_contact_params params
    
    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { 
          render :text=>"{success:true,
                          notice:'Contact #{params[:contact][:s_company_name]} was successfully updated.'}", :layout=>false
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:company_id])
    @contact.destroy
    
    respond_to do |format|
      format.html {  
        render :text=>"{success:true }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def comapanies_sharelist
    companies_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/contacts")
    Dir.foreach("#{RAILS_ROOT}/db/shared/contacts") { |x| companies_list.push({:company_name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => companies_list.to_xml }
      format.json { render :json => companies_list.to_json}
    end
  end
  
  def postdirectory
    contacts = Contact.find(:all, :conditions=>"id in (#{params[:items_list]})")
    
    if(params[:share].eql? "true")
      #Posted on Bloney Cashflow site  everybody could see it
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/contacts")
      File.open("#{RAILS_ROOT}/db/shared/contacts/#{session[:company].contact_name}.yml", 'w') {|f| f.write(contacts.to_yaml) }
    else
      #Posted on company site soe everybody could see it
      key = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{session[:company].contact_name}--")
      
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/contacts")
      File.open("#{RAILS_ROOT}/db/shared/contacts/#{session[:company].contact_name}_#{key}.yml", 'w') {|f| f.write(contacts.to_yaml) }
      
      params[:from] = "admin@bloney.co.cc"
      params[:to_company] = Contact.find(:first,:conditions=>"contact_name='#{params[:expert_name]}'")[:email]
      params[:subject] = "Contacts Directory"
      params[:email_editor] = "#{session[:company].contact_name} contacts directory is available for your usage. Activation key is :#{key} "
      UserNotifier.deliver_contactemail(params)
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Contacts directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
    logger.warn "  " + params[:items_list]
    contacts = YAML::load(File.open("#{RAILS_ROOT}/db/shared/contacts/#{params[:contact_name]}.yml" ))
    contacts.each do |item| 
      if(params[:items_list].include? ",#{item.attributes["id"]},")
        item.setAdobted(params[:contact_name])
        Contact.create(item.attributes)
      end
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Contacts directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/contacts")
      FileUtils.rm Dir.glob("#{session[:company].contact_name}*.yml")
    end
    
    if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
      Dir.chdir("#{RAILS_ROOT}/db/shared/contacts")
      FileUtils.rm Dir.glob("#{session[:company].contact_name}*.yml") 
    end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Contacts directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def sendmail
    params[:from] = "admin@bloney.co.cc"
    UserNotifier.deliver_contactemail(params) 
    
    respond_to do |format|
      format.html {
        render :text=>"{success:true,
                        notice:'Mail sent sucessfully ' }", :layout=>false
      }
      format.xml  { head :ok }
    end
    
  end
  
  def set_contact_params (params)
    params[:contact] = {
      :contact_name=>params[:s_company_name],
      :contact_type=>params[:abbrId],
      :city=>params[:s_city],
      :country=>params[:s_country],
      :address=>params[:s_address],
      :phone=>params[:s_phone],
      :fax=>params[:s_fax],
      :email=>params[:s_email],
      :url=>params[:s_url]
    }
  end
  
    # instance methods for cross-domain remote calls
  # GET /tasks/index_remote
  def index_remote
    all_tasks = Array.new
    if params[:tasklist_id].nil? 
      all_tasks = Task.find(:all) 
    else
       tasklist = Tasklist.find(:first, :conditions=>"listId='#{params[:tasklist_id]}'").full_set
       tasklist.each{|list| 
                        unless list.tasks.empty?
                          list.tasks.each{|task| all_tasks << task }  
                        end } 
    end
 
   
   task_list = all_tasks.map {|task| 
                 {
                  :taskId => task.taskId,
                  :title => task.title,
                  :description => task.description,
                  :dueDate => task.dueDate, 
                  :completed => task.completed,
                  :reminder => task.reminder,
                  :completedDate => task.completedDate,
                  :listId =>task.tasklists[0].id.to_s
                 } 
          } 
          
    @tasks_hash = Hash.new
    @tasks_hash[:Tasks] = task_list   
    @tasks_hash[:Total] = task_list.size

    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{task_list.to_json()});" }
      format.chr {render :chr=>@tasks_hash}
      format.jsonc {render :jsonc=>@tasks_hash}
    end
  end
  
  # GET /tasks/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:task].nil?
        task = ActiveSupport::JSON.decode(params[:task]).rehash
        logger.warn "decoded task from client#{task["dueDate"]}"
        tasklist = Tasklist.find(:first, :conditions=>"listId = '#{task["listId"]}'")
        task.delete("listId")
        @task = Task.new(task)
        @task.save 
        tasklist.tasks << @task
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Task was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /tasks/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:task].nil?
      task = ActiveSupport::JSON.decode(params[:task]).rehash
      @task = Task.find(:first , :conditions=>"taskId = '#{task["taskId"]}'")
      @task.tasklists << Tasklist.find(task["listId"])
      task.delete("listId")
      @task.update_attributes(task)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Task was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /tasks/destroy_remote/1
  def destroy_remote
    @task = Task.find(:first , :conditions=>"taskId = '#{params[:id]}'")
    @reply_remote = Hash.new()
    
    unless @task.nil?
       @task.destroy
       @reply_remote[:success]= true
    else
       @reply_remote[:success]= false
    end
   
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
      format.chr {render :chr=> @reply_remote}
      format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
end
