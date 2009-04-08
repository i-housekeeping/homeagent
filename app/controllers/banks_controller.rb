class BanksController < ApplicationController
  #before_filter :login_required
  
  #protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  
  # -- BATCHES
  def postdirectory
    
    banks_hash(params)
    params[:folder_name]=String.new("banks")
    params[:file_name]=String.new("banks")
    post_directory(params){@banks_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Banks directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    banks = YAML::load(File.open("#{RAILS_ROOT}/db/shared/banks/banks.yml" ))
    banks[:Banks].each do |item| 
      inject_banks (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Banks directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/banks")
      FileUtils.rm Dir.glob("banks.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Banks directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def banks_sharelist
    banks_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/banks")
    Dir.foreach("#{RAILS_ROOT}/db/shared/banks") { |x| banks_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => banks_list.to_xml }
      format.json { render :json => banks_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /banks/index_remote
  def index_remote
    
    banks_hash(params)

    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{bank_list.to_json()});" }
      format.chr {render :chr=>@banks_hash}
      format.jsonc {render :jsonc=>@banks_hash}
    end
  end
  
  # GET /banks/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:bank].nil?
        bank = ActiveSupport::JSON.decode(params[:bank]).rehash
        inject_banks(bank) 
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'bank was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /banks/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:bank].nil?
      bank = ActiveSupport::JSON.decode(params[:bank]).rehash
      @bank = bank.find(bank["bankId"])
      @bank.update_attributes(bank)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'bank was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /banks/destroy_remote/1
  def destroy_remote
    @bank = Bank.find(params[:bankId])
    @reply_remote = Hash.new()
    
    unless @bank.nil?
       @bank.destroy
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
  
 private
  
  def banks_hash (params)
    if params[:bankId].nil?
    @banks ||= Bank.find(:all)
   else
    @banks ||= Bank.find(params[:bankId])
   end
    banks_list = @banks.map {|bank| 
                 {
                  :bankId=>bank.id,
                  :name=>bank.name ,
                  :branch=>bank.branch ,
                  :address=>bank.address ,
                  :city=>bank.city ,
                  :country=>bank.country ,
                  :phone=>bank.phone ,
                  :fax=>bank.fax ,
                  :email=>bank.email ,
                  :url=>bank.url ,
                  :conn_person=>bank.conn_person ,
                  :businessdate=>bank.businessdate
                  }
          }
          
    @banks_hash = Hash.new
    @banks_hash[:Banks] = banks_list   
    @banks_hash[:Total] = banks_list.size
  end
  
  def inject_banks (bank)
       #if required the filtr should be here 
       bank.delete(:bankId)
       # ToDo check if record already exists
       Bank.create(bank)
  end
end
