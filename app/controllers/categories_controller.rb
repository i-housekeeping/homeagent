#require 'gruff'

class CategoriesController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator',
  #               :wizard => 'admin' 
  # GET /categories
  # GET /categories.xml
  def index(id = params[:node])
    @categories = Category.find(:all ,
                                :conditions=>"record_sts='ACTV'")
    Category.find_children(id).each{|item| item.fprint = form_authenticity_token}
    expand = params[:expanded].to_json
    if !params[:expanded].nil? 
      logger.warn expand.to_hash
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
      format.json { render :json => Category.find_children(id).each{|item| item.activate(form_authenticity_token)}}
      format.yaml { render  @categories.to_yaml}
    end
  end
  
  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
      format.yaml { render  @categories.to_yaml}
    end
  end
  
  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end
  
  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end
  
  # POST /categories
  # POST /categories.xml
  def create
    
    params[:category] = {
      :text=>params[:category],
      :description=>params[:description],
      :record_sts=>params[:statusId]
    } 
    
    @category = Category.create(params[:category])
    
    respond_to do |format|
      if Category.find(params[:parent_categoryid]).add_child(@category)
        #flash[:notice] = 'Category was successfully created.'
        Story.new().create_story(@category, current_user)
        format.html { #redirect_to(@category) 
          render :text=>"{success:true,
                       notice:'Category #{params[:category][:text]} was successfully created.'}", :layout=>false
        }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:category_id])
    
    params[:category] = {
      :text=>params[:category],
      :description=>params[:description],
      :record_sts=>params[:statusId]
    } 
    
    respond_to do |format|
      if @category.update_attributes(params[:category])
        Story.new().update_story(@category, current_user,params[:story])
        format.html { #redirect_to(@category) 
          render :text=>"{success:true,
                       notice:'Category #{params[:category][:text]} was successfully updated.'}", :layout=>false
        }
        format.xml  { head :ok }
        
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    #@category.destroy
    @category.record_sts = "DELT" 
    @category.save
    Story.new().delete_story(@category, current_user)
    
    respond_to do |format|
      format.html { #redirect_to(categories_url) 
        render :text=>"{success:true,
                        notice:'Category #{@category.text} was successfully deleted.'}", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def upload
      file = params[params[:input_id]].read
      file_name = params[params[:input_id]].original_filename
      logger.warn " File name : " + file_name
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/upload/categories")
      File.open("#{RAILS_ROOT}/db/upload/categories/#{file_name}", 'wb') {|f| f.write(file) }
      render :text=>"{success:true}", :layout=>false
  end
  #TODO Implement in next release
  def progress
    #render :text=>"{success:true}", :layout=>false
  end
  
  def stories
    return_data = Hash.new()
    return_data [:data] = Category.find(params[:id]).stories
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => return_data }
      format.json { render :json => return_data}
    end
  end
  
  def graph_report(graph_type = params[:graph_type], filename = params[:filename])
    FileUtils.rm_rf("public/images/pie_keynote.png")
    
    case graph_type
      when "pie"
      g = Gruff::Pie.new(400)    
      when "line"
      g = Gruff::Line.new(400)    
      when "bar"
      g = Gruff::Bar.new(400)    
    else
      g = Gruff::Pie.new(400)
    end
    
    g.title = "Categories Usage"
    #TODO need to add the real data to the graph
    g.data 'Investements', 20
    g.data 'Loans', 50
    g.data 'Salaries', 25
    g.data 'Interest', 37
    g.data 'Sales', 14
    g.write("public/images/#{filename}")
    
    render :text=>"{success:true}", :layout=>false
  end
  
  def wizard
    return false if !Category.find(:first).nil?
    
    categories = YAML::load(File.open("#{RAILS_ROOT}/db/initializers/categories.yml" ))
    
    categories.sort_by{|key , value| key[/_[0-9A-Za-z]+/] }.each do |k,v|    
      v[:categories]=Category.create(v)
      Story.new().create_story(v[:categories], current_user)
      if k != "aroot_aroot" 
        parent_key = "_" + k[/[0-9A-Za-z]+_/][0...-1]
        categories.each_key {|key| if key[/_[0-9A-Za-z]+/] == parent_key 
            categories.fetch(key)[:categories].add_child(v[:categories])
            end}
        end       
      end
      
      render :action=>"index", :layout=>false
    end
    
    protected
    
    def permission_denied
      render :text=>"{success:false,
                      notice:'Failed to Login !!!'}", :layout=>false
      #flash[:notice] = "You don't have privileges to access this action"
      #return redirect_to :action => 'denied'
    end
    
    def permission_granted
      # render :text=>"{success:true,
      #                 url:'/helps/index',
      #                 notice:'Logged in successfully'}", :layout=>false
      #flash[:notice] = "Welcome to the secure area of foo.com!"
    end
  end
