class TasklistsController < ApplicationController
  # GET /tasklists
  # GET /tasklists.xml
  def index(id = params[:node])
   logger.warn " tasklists id is #{id}"
   if id.nil?
    @tasklists = Tasklist.find(:all)
   else
    @tasklists = Tasklist.find_children(id)
   end
   
   @tasklists_hash = Hash.new
   task_list = @tasklists.map {|task| 
                 {
                  :listId => task.id,
                  :parentId => task.parent_id.nil? ? "root" : task.parent_id ,
                  :listName => task.text,
                  :description => task.description,
                  :isFolder=> task.children_count == 0 ? false : true
                  }
          }
    @tasklists_hash[:Tasklists] = task_list   
    @tasklists_hash[:Total] = task_list.size
    
    logger.warn "Taskslist in json : #{@tasklists_hash.to_json}"   
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasklists }
      format.js { render :js => "#{params[:callback]}(#{@tasklists.each{|item| item.activate(form_authenticity_token)}.to_json});" }
      format.chr {render :chr=>@tasklists.each{|item| item.activate(form_authenticity_token)}}
      format.jsonc {render :jsonc=>@tasklists_hash}
      format.yaml { render  @tasklists.to_yaml}
    end
  end

  # GET /tasklists/1
  # GET /tasklists/1.xml
  def show
    @tasklist = Tasklist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tasklist }
    end
  end

  # GET /tasklists/new
  # GET /tasklists/new.xml
  def new
    @tasklist = Tasklist.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tasklist }
    end
  end

  # GET /tasklists/1/edit
  def edit
    @tasklist = Tasklist.find(params[:id])
  end

  # POST /tasklists
  # POST /tasklists.xml
  def create
    @tasklist = Tasklist.new(params[:tasklist])

    respond_to do |format|
      if @tasklist.save
        flash[:notice] = 'Tasklist was successfully created.'
        format.html { redirect_to(@tasklist) }
        format.xml  { render :xml => @tasklist, :status => :created, :location => @tasklist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tasklist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasklists/1
  # PUT /tasklists/1.xml
  def update
    @tasklist = Tasklist.find(params[:id])

    respond_to do |format|
      if @tasklist.update_attributes(params[:tasklist])
        flash[:notice] = 'Tasklist was successfully updated.'
        format.html { redirect_to(@tasklist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tasklist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasklists/1
  # DELETE /tasklists/1.xml
  def destroy
    @tasklist = Tasklist.find(params[:id])
    @tasklist.destroy

    respond_to do |format|
      format.html { redirect_to(tasklists_url) }
      format.xml  { head :ok }
    end
  end
  
  def wizard
    return false unless Tasklist.find(:first).nil?
    
    tasklists = YAML::load(File.open("#{RAILS_ROOT}/db/initializers/tasklists.yml" ))
    
    tasklists.sort_by{|key , value| key[/_[0-9A-Za-z]+/] }.each do |k,v|    
      v[:tasklists]=Tasklist.create(v)
      #Story.new().create_story(v[:categories], current_user)
      if k != "aroot_aroot" 
        parent_key = "_" + k[/[0-9A-Za-z]+_/][0...-1]
        tasklists.each_key {|key| if key[/_[0-9A-Za-z]+/] == parent_key 
            tasklists.fetch(key)[:tasklists].add_child(v[:tasklists])
            end}
        end       
      end
      
      render :action=>"index", :layout=>false
    end
end
