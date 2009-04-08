class TasksController < ApplicationController
  
  
  # -- BATCHES
  def postdirectory
    
    tasks_hash(params)
    params[:folder_name]=String.new("tasks")
    params[:file_name]=String.new("tasks")
    post_directory(params){@tasks_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Tasks directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    tasks = YAML::load(File.open("#{RAILS_ROOT}/db/shared/tasks/tasks.yml" ))
    tasks[:Tasks].each do |item| 
      inject_tasks (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Tasks directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/tasks")
      FileUtils.rm Dir.glob("tasks.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Tasks directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def tasks_sharelist
    tasks_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/tasks")
    Dir.foreach("#{RAILS_ROOT}/db/shared/tasks") { |x| tasks_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => tasks_list.to_xml }
      format.json { render :json => tasks_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /tasks/index_remote
  def index_remote
    all_tasks = Array.new
     
    unless params[:tasklist_id].nil?
       tasklist = Tasklist.find(:first, :conditions=>"listId='#{params[:tasklist_id]}'").full_set
       tasklist.each{|list| 
                        unless list.tasks.empty?
                          list.tasks.each{|task| all_tasks << task }  
                        end } 
    end
    
    unless params[:reminder_time].nil?
       all_tasks = Task.find(:all, :conditions=>"completed = 'f' AND reminder <> '' AND reminder <='#{params[:reminder_time]}'")
    else
       all_tasks = Task.find(:all) 
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
                  :listId =>task.tasklists[0].listId.to_s
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
      @task.tasklists << Tasklist.find(:first, :conditions=>"listId='#{task["listId"]}'")
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
  
  private
  
  def tasks_hash (params)
    if params[:taskId].nil?
    @tasks ||= Task.find(:all)
   else
    @tasks ||= Task.find(params[:taskId])
   end
    tasks_list = @tasks.map {|task| 
                 {
                  :taskId=>task.taskId,
                  :title => task.title,
                  :description => task.description,
                  :dueDate => task.dueDate, 
                  :completed => task.completed,
                  :reminder => task.reminder,
                  :completedDate => task.completedDate,
                  :listId =>task.tasklists[0].listId.to_s
                  }
          }
          
    @tasks_hash = Hash.new
    @tasks_hash[:Tasks] = tasks_list   
    @tasks_hash[:Total] = tasks_list.size
  end
  
  def inject_tasks (task)
       #if required the filtr should be here 
       task.delete(:taskId)
       # ToDo check if record already exists
       Task.create(task)
  end
end
