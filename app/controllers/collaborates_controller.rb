class CollaboratesController < ApplicationController
 
  # -- BATCHES
  def postdirectory
    
    collaborates_hash(params)
    params[:folder_name]=String.new("collaborates")
    params[:file_name]=String.new("collaborates")
    post_directory(params){@collaborates_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Collaborates directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    collaborates = YAML::load(File.open("#{RAILS_ROOT}/db/shared/collaborates/collaborates.yml" ))
    collaborates[:Collaborates].each do |item| 
      inject_collaborates (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Collaborates directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/collaborates")
      FileUtils.rm Dir.glob("collaborates.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Collaborates directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def collaborates_sharelist
    collaborates_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/collaborates")
    Dir.foreach("#{RAILS_ROOT}/db/shared/collaborates") { |x| collaborates_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => collaborates_list.to_xml }
      format.json { render :json => collaborates_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /collaborates/index_remote
  def index_remote
   
    collaborates_hash(params)
  
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{collaborate_list.to_json()});" }
      format.chr {render :chr=>@collaborates_hash}
      format.jsonc {render :jsonc=>@collaborates_hash}
    end
  end
  
  # GET /collaborates/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:collaborate].nil?
        collaborate = ActiveSupport::JSON.decode(params[:collaborate]).rehash
        inject_collaborate(collaborate)
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Collaborate was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /collaborates/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:collaborate].nil?
      collaborate = ActiveSupport::JSON.decode(params[:collaborate]).rehash
      @collaborate = Collaborate.find(collaborate["collaborateId"])
      @collaborate.update_attributes(collaborate)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Collaborate was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /collaborates/destroy_remote/1
  def destroy_remote
    @collaborate = Collaborate.find(params[:collaborateId])
    @reply_remote = Hash.new()
    
    unless @collaborate.nil?
       @collaborate.destroy
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
  
  def collaborates_hash (params)
    if params[:collaborateId].nil?
    @collaborates ||= Collaborate.find(:all)
   else
    @collaborates ||= Collaborate.find(params[:collaborateId])
   end
    collaborates_list = @collaborates.map {|collaborate| 
                 {
                    :collaborateId=>collaborate.id,
                    :user_id=>cookies[:current_user_id], 
                    :task_id=>collaborate.task.id, 
                    :cashrecord_id=>collaborate.cashrecord.id,
                    :link_to=>collaborate.link_to,
                    :action_to=>collaborate.action_to,
                    :auth_type=>collaborate.auth_type,
                    :login=>collaborate.login,
                    :password=>collaborate.password
                  }
          }
          
    @collaborates_hash = Hash.new
    @collaborates_hash[:Collaborates] = collaborates_list   
    @collaborates_hash[:Total] = collaborates_list.size
  end
  
  def inject_collaborates (collaborate)
       #if required the filtr should be here 
      collaborate.delete(:collaborateId)
       # ToDo check if record already exists
      Collaborate.create(collaborate)
  end
  
end
