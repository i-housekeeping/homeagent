#include Ruleby

#class Message
#  def initialize(status,message)
#    @status = status
#    @message = message
#  end
#  attr :status, true
#  attr :message, true
#end
 
#class HelloWorldRulebook < Rulebook
#  def rules
#    rule [Message, :m, m.status == :HELLO] do |v|
#      puts v[:m].message
#      v[:m].message = "Goodbye world"
#      v[:m].status = :GODBYE
#      modify v[:m]
#    end
#   
#    rule [Message, :m, m.status == :GOODBYE] do |v| 
#      puts v[:m].message 
#   end       
#  end
#end


class AlertsController < ApplicationController
  # GET /alerts
  # GET /alerts.xml
  def index(id = params[:node])
    @alerts = Alert.find(:all,
                         :conditions=>"record_sts='ACTV'")

    Alert.find_children(id).each{|item| item.text = form_authenticity_token}
    expand = params[:expanded].to_json
    if !params[:expanded].nil? 
      logger.warn expand.to_hash
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alerts }
      format.json { render :json => Alert.find_children(id).each{|item| item.activate(form_authenticity_token)}}
      format.yaml { render  @alerts.to_yaml}
    end    
  end

  # GET /alerts/1
  # GET /alerts/1.xml
  def show
    
   # engine :engine do |e|
   #   HelloWorldRulebook.new(e).rules
   #   e.assert Message.new(:HELLO, 'Hello World')
   #   e.match
   # end
    
    
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # GET /alerts/new
  # GET /alerts/new.xml
  def new
    @alert = Alert.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # GET /alerts/1/edit
  def edit
    @alert = Alert.find(params[:id])
  end

  # POST /alerts
  # POST /alerts.xml
  def create
    @alert = Alert.new(params[:alert])

    respond_to do |format|
      if @alert.save
        flash[:notice] = 'Alert was successfully created.'
        format.html { redirect_to(@alert) }
        format.xml  { render :xml => @alert, :status => :created, :location => @alert }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alerts/1
  # PUT /alerts/1.xml
  def update
    @alert = Alert.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(params[:alert])
        flash[:notice] = 'Alert was successfully updated.'
        format.html { redirect_to(@alert) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.xml
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to(alerts_url) }
      format.xml  { head :ok }
    end
  end
  
  def wizard
    return false if !Category.find(:first).nil?
    
    alerts = YAML::load(File.open("#{RAILS_ROOT}/db/initializers/alerts.yml" ))
    
    alerts.sort_by{|key , value| key[/_[0-9A-Za-z]+/] }.each do |k,v|    
      v[:alerts]=Alert.create(v)
      Story.new().create_story(v[:alerts], current_user)
      if k != "aroot_aroot" 
        parent_key = "_" + k[/[0-9A-Za-z]+_/][0...-1]
        alerts.each_key {|key| if key[/_[0-9A-Za-z]+/] == parent_key 
            alerts.fetch(key)[:alerts].add_child(v[:alerts])
            end}
        end       
      end
      
      render :action=>"index", :layout=>false
    end
end
