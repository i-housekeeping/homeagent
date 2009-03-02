class NotificationsController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  # GET /notifications
  # GET /notifications.xml
  def index
    @notifications = Notification.find(:all)
        
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notifications }
      format.json { render :json=> @notifications}
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @notification  = Notification.find(:first,
                                       :conditions => " notification_status = '#{params[:notification_status]}'",
                                       :order=>"last_update #{params[:next]}",
                                       :offset => (params[:next] == 'DESC' ? 1 : 0) )
    if (@notification != nil) 
      @notification.reset_time 
      @notification.update_attributes(@notification.attributes)
    else
      @notification = Notification.new
      @notification.content = "There are no items to display"
      @notification.notification_type = ""
    end
    
    #@notification = Notification.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
      format.json { render :text=> '[' + @notification.to_json + ']' }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.xml
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.xml
  def create
    params[:notification] = {
          :notification_type => params[:notification_type], 
          :content => params[:notification_editor],
          :user_id => current_user.id,
          :notification_status => params[:notification_status]
          }
    @notification = Notification.new(params[:notification])

    respond_to do |format|
      if @notification.save
        #flash[:notice] = 'Notification was successfully created.'
        format.html { #redirect_to(@notification)
              render :text=>"{success:true,
                              notice:'Notification was successfully created.',
                              notification_id : #{@notification.id}}", :layout=>false
         }
        format.xml  { render :xml => @notification, :status => :created, :location => @notification }
      else
        format.html { #render :action => "new" 
              render :text=>"{success:true,
                              notice:'Notification was failed created.',
                            }", :layout=>false}
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.xml
  def update
    @notification = Notification.find(params[:id])
    
    params[:notification] = {
              :notification_type => params[:notification_type], 
              :content => params[:content],
              :user_id => params[:user_id],
              :notification_status => params[:notification_status]
          }
    

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        #flash[:notice] = 'Notification was successfully updated.'
        format.html { #redirect_to(@notification) 
            render :text=>"{success:true,
                           notice:'Notification was failed to update.',
                            }", :layout=>false
        }
        format.xml  { head :ok }
      else
        format.html { #render :action => "edit"
          render :text=>"{success:false,
                              notice:'Notification was failed to upadte.',
                            }", :layout=>false 
        }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.xml
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end
end
