class ContactsController < ApplicationController
 #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'  
  
  # -- BATCHES
  def postdirectory
    
    contacts_hash(params)
    params[:folder_name]=String.new("contacts")
    params[:file_name]=String.new("contacts")
    post_directory(params){@contacts_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Contacts directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    contacts = YAML::load(File.open("#{RAILS_ROOT}/db/shared/contacts/contacts.yml" ))
    contacts[:Contacts].each do |item| 
      inject_contacts (item) 
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
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/contacts")
      FileUtils.rm Dir.glob("contacts.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Contacts directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def contacts_sharelist
    contacts_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/contacts")
    Dir.foreach("#{RAILS_ROOT}/db/shared/contacts") { |x| contacts_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => contacts_list.to_xml }
      format.json { render :json => contacts_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /contacts/index_remote
  def index_remote
   
    contacts_hash(params)
  
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{contact_list.to_json()});" }
      format.chr {render :chr=>@contacts_hash}
      format.jsonc {render :jsonc=>@contacts_hash}
    end
  end
  
  # GET /contacts/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:contact].nil?
        contact = ActiveSupport::JSON.decode(params[:contact]).rehash
        inject_contact(contact)
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Contact was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /contacts/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:contact].nil?
      contact = ActiveSupport::JSON.decode(params[:contact]).rehash
      @contact = Contact.find(contact["contactId"])
      @contact.update_attributes(contact)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Contact was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /contacts/destroy_remote/1
  def destroy_remote
    @contact = Contact.find(params[:contactId])
    @reply_remote = Hash.new()
    
    unless @contact.nil?
       @contact.destroy
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
  
  def contacts_hash (params)
    if params[:contactId].nil?
    @contacts ||= Contact.find(:all)
   else
    @contacts ||= Contact.find(params[:contactId])
   end
    contacts_list = @contacts.map {|contact| 
                 {
                  :contactId=>contact.id,
                  :contact_name=>contact.contact_name ,
                  :contact_type=>contact.contact_type ,
                  :address=>contact.address ,
                  :city=>contact.city ,
                  :country=>contact.country ,
                  :phone=>contact.phone ,
                  :fax=>contact.fax ,
                  :email=>contact.email ,
                  :url=>contact.url 
                  }
          }
          
    @contacts_hash = Hash.new
    @contacts_hash[:Contacts] = contacts_list   
    @contacts_hash[:Total] = contacts_list.size
  end
  
  def inject_contacts (contact)
       #if required the filtr should be here 
      contact.delete(:contactId)
       # ToDo check if record already exists
      Contact.create(contact)
  end
  
end
