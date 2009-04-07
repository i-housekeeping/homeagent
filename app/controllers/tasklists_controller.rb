class TasklistsController < ApplicationController
   
  def wizard
    return false unless Tasklist.find(:first).nil?
    
    tasklists = YAML::load(File.open("#{RAILS_ROOT}/db/initializers/tasklists.yml" ))
    
    tasklists.sort_by{|key , value| key[/_[0-9A-Za-z]+/] }.each do |k,v|    
      v[:parent_id] = k[0..k.index("_")-1]
      v[:listId] = k[k.rindex("_")+1..k.size]
      new_tasklist =Tasklist.new(v)
      #Story.new().create_story(v[:categories], current_user)
       if k != "aroot_aroot" 
            Tasklist.find(:first, :conditions=>"listId = '#{v[:parent_id]}'").add_child(new_tasklist)
       else
        new_tasklist[:parent_id] = 0
        new_tasklist.save
       end       
      end
      
      render :action=>"index", :layout=>false
  end
  
  def postdirectory
    
    tasklists_hash(params)
    @tasklists_hash[:Tasklists].each{|item|}  
    
    #if(params[:share].eql? "true")
      #Posted on Bloney Cashflow site  everybody could see it
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/tasklists")
      File.open("#{RAILS_ROOT}/db/shared/tasklists/test.yml", 'w') {|f| f.write(@tasklists_hash.to_yaml) }
    #else
      #Posted on company site soe everybody could see it
      #key = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{session[:company].customer_name}--")
      
      #FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
      #File.open("#{RAILS_ROOT}/db/shared/customers/#{session[:company].customer_name}_#{key}.yml", 'w') {|f| f.write(customers.to_yaml) }
      
      #params[:from] = "admin@bloney.co.cc"
      #params[:to_company] = Customer.find(:first,:conditions=>"customer_name='#{params[:expert_name]}'")[:email]
      #params[:subject] = "Customers Directory"
      #params[:email_editor] = "#{session[:company].customer_name} customers directory is available for your usage. Activation key is :#{key} "
      #UserNotifier.deliver_customeremail(params)
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Customers directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    tasklists = YAML::load(File.open("#{RAILS_ROOT}/db/shared/tasklists/test.yml" ))
    tasklists[:Tasklists].each do |item| 
      inject_tasklist (item) 
      if item[:isFolder] == false
          task = Task.new({
                        :taskId => item[:listId],
                        :title => item[:listName],
                        :description => item[:description],
                        :dueDate => "", 
                        :completed => false,
                        :reminder => "",
                        :completedDate => ""
                       } )
          task.save 
          Tasklist.find(:first, :conditions=>{:listId=>item[:listId]}).tasks << task
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
  
  def tasklists_sharelist
    companies_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
    Dir.foreach("#{RAILS_ROOT}/db/shared/customers") { |x| companies_list.push({:company_name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => companies_list.to_xml }
      format.json { render :json => companies_list.to_json}
    end
  end
  # instance methods for cross-domain remote calls
  # GET /tasks/index_remote
  def index_remote()
   
    tasklists_hash(params)
    
    logger.warn "Taskslist in json : #{@tasklists_hash.to_json}"   
    
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{@tasklists.each{|item| item.activate(form_authenticity_token)}.to_json});" }
      format.chr {render :chr=>@tasklists.each{|item| item.activate(form_authenticity_token)}}
      format.jsonc {render :jsonc=>@tasklists_hash}
    end
  end
  
  # GET /tasks/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:tasklist].nil?
        tasklist = ActiveSupport::JSON.decode(params[:tasklist]).rehash      
        tasklist[:user_id] = cookies[:current_user_id]        
        inject_tasklist (tasklist)
        @reply_remote[:status]= "success"
        @reply_remote[:notice] = 'Task was successfully created.'
    else
        @reply_remote[:status]= "failure"
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
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
    
    unless params[:tasklist].nil?
      tasklist = ActiveSupport::JSON.decode(params[:tasklist]).rehash
      tasklist.delete("isFolder")
      tasklist.delete("parentId")
      @tasklists = Tasklist.find(:first , :conditions=>"listId = '#{tasklist["listId"]}'")
      @tasklists.update_attributes(tasklist)
      @reply_remote[:status]= "success"
      @reply_remote[:notice] = 'Task was successfully updated.'
   else
       @reply_remote[:status]= "failure"
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /tasks/destroy_remote/1
  def destroy_remote
    @tasklist = Tasklist.find(:first , :conditions=>"listId = '#{params[:listId]}'")
    @reply_remote = Hash.new()
    
    unless @tasklist.nil?
       @tasklist.destroy
       @reply_remote[:status]= "success"
    else
       @reply_remote[:status]= "failure"
    end
   
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
      format.chr {render :chr=> @reply_remote}
      format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  private
  
  def tasklists_hash (params)
    if params[:tasklist_id].nil?
    @tasklists ||= Tasklist.find(:all)
   else
    @tasklists ||= Tasklist.find(:first , :conditions=>"listId = '#{params[:tasklist_id]}'").full_set
   end
  
   @tasklists_hash = Hash.new
   task_list = @tasklists.map {|tasklist| 
                 {                 
                  :listId => tasklist.listId,
                  :parentId => tasklist.parent_id == 0 ? "root" : Tasklist.find(tasklist.parent_id).listId ,
                  :listName => tasklist.listName,
                  :description => tasklist.description,
                  :isFolder=> tasklist.isFolder
                  }
          }
    @tasklists_hash[:Tasklists] = task_list   
    @tasklists_hash[:Total] = task_list.size
  end
  
  def inject_tasklist (tasklist)
        
        if ("root".eql?(tasklist[:parentId].to_s) || "root".eql?(tasklist["parentId"].to_s))  
          tasklist[:parent_id] = 0
          tasklist.delete(:parentId)
          tasklist.delete("parentId")
          Tasklist.create(tasklist)
        else
          tasklist[:parent_id] = tasklist[:parentId] ||tasklist["parentId"] 
          tasklist.delete("parentId")
          tasklist.delete(:parentId)
          Tasklist.find(:first, :conditions=>"listId = '#{tasklist[:parent_id]}'").add_child(Tasklist.create(tasklist))
        end
  end
end
