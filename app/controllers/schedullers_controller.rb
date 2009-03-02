require 'atom/feed'
require 'rubygems'
require 'rufus/scheduler'

class PicSelectionProcess < OpenWFE::ProcessDefinition
 
  sequence do
     alpha
  end
end



class SchedullersController < ApplicationController
  # GET /schedullers
  # GET /schedullers.xml
  def index
    @s = Rufus::Scheduler.start_new  
  
    @s.every "1m", :timeout => "1m" do  
      puts "Test ..."
      @s.stop
    end
    
    @schedullers = Scheduller.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedullers }
    end
  end

  # GET /schedullers/1
  # GET /schedullers/1.xml
  def show
   
    
    #@scheduller = Scheduller.find(params[:id])

    #respond_to do |format|
   #   format.html # show.html.erb
   #   format.xml  { render :xml => @scheduller }
   # end
  end

  # GET /schedullers/new
  # GET /schedullers/new.xml
  def new
    @scheduller = Scheduller.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scheduller }
    end
  end

  # GET /schedullers/1/edit
  def edit
    @scheduller = Scheduller.find(params[:id])
  end

  # POST /schedullers
  # POST /schedullers.xml
  def create
    @scheduller = Scheduller.new(params[:scheduller])

    respond_to do |format|
      if @scheduller.save
        flash[:notice] = 'Scheduller was successfully created.'
        format.html { redirect_to(@scheduller) }
        format.xml  { render :xml => @scheduller, :status => :created, :location => @scheduller }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scheduller.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedullers/1
  # PUT /schedullers/1.xml
  def update
    @scheduller = Scheduller.find(params[:id])

    respond_to do |format|
      if @scheduller.update_attributes(params[:scheduller])
        flash[:notice] = 'Scheduller was successfully updated.'
        format.html { redirect_to(@scheduller) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scheduller.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedullers/1
  # DELETE /schedullers/1.xml
  def destroy
    @scheduller = Scheduller.find(params[:id])
    @scheduller.destroy

    respond_to do |format|
      format.html { redirect_to(schedullers_url) }
      format.xml  { head :ok }
    end
  end
  
  def workflow
    
    ruote_engine.register_participant("alpha", :position => :first) do
      puts "first !"
    end
    
    li = OpenWFE::LaunchItem.new(PicSelectionProcess)
    #li.tags = [ 'lamp', 'fish' ]
     
    fei = ruote_engine.launch(li)
    #ruote_engine.wait_for(fei)
  end
  
end
