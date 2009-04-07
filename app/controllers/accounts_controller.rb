class AccountsController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.find(:all,
                             :conditions=>"record_sts='ACTV'")
    
    if (@accounts.size == 0)
      @accounts << Account.new
      @accounts[0].customer_type = params[:account_type]
      @accounts[0][:authenticity_token] = form_authenticity_token
    else
      @accounts.map{|acc| acc[:authenticity_token] = form_authenticity_token }
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
      format.json { render :json => @accounts}
    end
  end
  
  def index_tree
    accounts = Account.find(:all,
                            #:select=>"id,account_no,account_type,balance",
                            :conditions=>"record_sts='ACTV'")
    accounts.map{|acc| acc[:authenticity_token] = form_authenticity_token
                       acc[:bank] = Bank.find(acc.bank_id) }  
                       
    accounts.map{|acc| acc[:leaf] = true 
                      acc[:uiProvider] = 'col'}
                       
    account_types = Account.find(:all, :select=>"distinct account_type") 
    
    account_types.each{|acctype| acctype[:uiProvider] = 'col'
                                 acctype[:authenticity_token] = form_authenticity_token
                                 acctype[:children] = accounts.find_all {|acc| acc.account_type == acctype.account_type } }
       
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => account_types }
      format.json { render :json => account_types}
    end
  end
  
  def virtual_tree
    accounts = Account.find(:all,
                            :select=>"id,account_no,account_type,balance",
                            :conditions=>"record_sts='ACTV'")
                            
   accounts.map{|acc| acc[:leaf] = true 
                      acc[:text] = acc.account_no}
                       
       
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => accounts }
      format.json { render :json => accounts}
    end
  end
  
  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end
  
  # POST /accounts
  # POST /accounts.xml
  def create
    set_account_params params
    @account = Account.new(params[:account])
    
    respond_to do |format|
      if @account.save
        Note.new().create_story(@account, current_user)
        format.html { 
          render :text=>"{success:true,
                          notice:'Account #{params[:account][:account_no]} was successfully created.'}", :layout=>false
        }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:account_id])
    set_account_params params
    
    respond_to do |format|
      if @account.update_attributes(params[:account])
        Note.new().update_story(@account, current_user,params[:story])
        format.html { 
          render :text=>"{success:true,
                          notice:'Account #{params[:account][:account_no]} was successfully updated.'}", :layout=>false
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:account_id])
    @account.destroy
    Note.new().delete_story(@account, current_user)
    
    respond_to do |format|
      format.html {  
        render :text=>"{success:true }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def stories
    return_data = Hash.new()
    return_data [:data] = Account.find((params[:id].to_i == 0) ? :first : params[:id]).stories 
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => return_data }
      format.json { render :json => return_data}
    end
  end
  
  def set_account_params (params)
    params[:account] = {
      :account_no=>params[:accountnumber],
      :account_type=>params[:accounttype],
      :currency=>params[:accountcurrency],
      :balance=>params[:accountbalance],
      :credit_limit=>params[:accountcrlimit],
      :balance_date=>params[:accountbalancedate]
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
