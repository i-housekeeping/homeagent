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
end
