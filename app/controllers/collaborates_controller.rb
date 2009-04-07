class CollaboratesController < ApplicationController
  # GET /collaborates
  # GET /collaborates.xml
  def index
    @collaborates = Collaborate.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaborates }
    end
  end

  # GET /collaborates/1
  # GET /collaborates/1.xml
  def show
    @collaborate = Collaborate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collaborate }
    end
  end

  # GET /collaborates/new
  # GET /collaborates/new.xml
  def new
    @collaborate = Collaborate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaborate }
    end
  end

  # GET /collaborates/1/edit
  def edit
    @collaborate = Collaborate.find(params[:id])
  end

  # POST /collaborates
  # POST /collaborates.xml
  def create
    @collaborate = Collaborate.new(params[:collaborate])

    respond_to do |format|
      if @collaborate.save
        flash[:notice] = 'Collaborate was successfully created.'
        format.html { redirect_to(@collaborate) }
        format.xml  { render :xml => @collaborate, :status => :created, :location => @collaborate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collaborate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collaborates/1
  # PUT /collaborates/1.xml
  def update
    @collaborate = Collaborate.find(params[:id])

    respond_to do |format|
      if @collaborate.update_attributes(params[:collaborate])
        flash[:notice] = 'Collaborate was successfully updated.'
        format.html { redirect_to(@collaborate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collaborate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collaborates/1
  # DELETE /collaborates/1.xml
  def destroy
    @collaborate = Collaborate.find(params[:id])
    @collaborate.destroy

    respond_to do |format|
      format.html { redirect_to(collaborates_url) }
      format.xml  { head :ok }
    end
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
