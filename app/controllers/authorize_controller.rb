class AuthorizeController < ApplicationController
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie
  layout "authorize"
  protect_from_forgery :only => [:create,  :destroy]
  
  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end
  
  def roles
    @roles ||= Role.find(:all, 
                         :select=>"title,description",
                         :conditions=>"record_sts='ACTV'",
                         :group=>"title")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
      format.json { render :json => @roles}
    end
  end
  
  def domains
    @roles ||= Role.find(:all, 
                         :select=>"domain,domain_description",
                         :conditions=>"record_sts='ACTV'",
                         :group=>"domain")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
      format.json { render :json => @roles}
    end
  end
  
  def welcome
    #TODO somehting here  
  end
  
  def user_list(role_type = params[:role_type] )
    
    users ||= User.find(:all) 
    
    if !role_type.nil?    
      users =  users.find_all{|elem| elem.roles[0].role_group == role_type } 
    end
    
    logger.warn users.size().to_s
    
    users_list = users.map {|user| {
        :id => user.id,
        :login => user.login,
        :email => user.email,
        :role => user.roles[0].title,
        :domain => user.roles[0].domain,
        :active => user.activation_code.nil? ? "Yes" : "No"
      } }
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => users_list }
      format.json { render :json => users_list }
    end
  end
  
  def login
    
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "on"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      
      render :text=>"{success:true,
                      url:'/',
                      notice:'Logged in successfully'}", :layout=>false
    else
      render :text=>"{success:false,
                      notice:'Failed to Login !!!'}", :layout=>false
    end
  end
  
  
  def signup
    return unless request.post?
    @user = User.new( :login=>params[:login],
                     :email=>params[:email],
                     :password=>params[:password], 
                     :password_confirmation=>params[:password_confirmation])
    #TODO change the role
    @role ||= Role.find(:first, :conditions=>"domain = '#{params[:domainId]}'")
    @user.roles << @role
    if(@user.save)
      render :text=>"{success:true,
                      url:'/authorize/welcome',
                      notice:'Thanks for signing up!'}", :layout=>false
      
    else
      notice = ''
      @user.errors.each_full{|msg| notice+= msg + " </br>" }
      render :text=>"{success:false,
                      url:'/authorize/signup',
                      notice:'#{notice}'}", :layout=>false
    end
  end
  
  def update
    return unless request.post?
    @user = User.find(params[:id])
    #@user.attributes.each_pair{|key,value|   if params[key].nil?   puts key + " => "+ value.to_s}
    @user.attribute_names.each{|elem| logger.warn "User Element: #{elem}"}
    @user.attribute_names.each{|elem| logger.warn "Element: #{elem} and value: #{params[elem]}" unless params[elem].nil?}
    
    respond_to do |format|
      if @user.save
        flash[:notice] = 'Customer was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    #flash[:notice] = "You have been logged out."
    #redirect_back_or_default(:controller => '/authorize', :action => 'login')
    render :text=>"{success:true,
                      url:'/authorize/login',
                      notice:'You have been logged out.'}", :layout=>false
  end
  
  def activate
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      #self.current_user = @user
      flash[:success] = "true"
      flash[:notice] = "Your account has been activated"    
    else 
      flash[:success] = "false"
      flash[:notice] = "There are some porblems with signup"   
    end
    render :layout=>true
    #redirect_back_or_default(:controller => '/authorize', :action => 'login')
  end
  
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      render :text=>"{success:true,
                      url:'/authorize/login',
                      notice:'A password reset link has been sent to your email address'}", :layout=>false
    else
      render :text=>"{success:false,
                      url:'/authorize/login',
                      notice:'Could not find a user with that email address'}", :layout=>false
    end
  end
  
  def reset_password
    return if params[:id].nil?
    @user = User.find_by_password_reset_code(params[:id])
    raise if @user.nil?
    return if @user unless params[:password]
    if (params[:password] == params[:password_confirmation])
      @user.password_confirmation = params[:password_confirmation]
      @user.password = params[:password]      
      @user.reset_password
      #@user.login = params[:login] unless params[:login].nil?
      #@user.email = params[:email] unless params[:email].nil?  
      
      if(@user.save)
        render :text=>"{success:true,
                      url:'/authorize/login',
                      notice:'Thanks for updating details!'}", :layout=>false
      else
        notice = ''
        @user.errors.each_full{|msg| notice+= msg + " </br>" }
        render :text=>"{success:false,
                      url:'/authorize/signup',
                      notice:'#{notice}'}", :layout=>false
      end
      #flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
      #flash[:success] = "true"
    else
      #flash[:success] = "false"
      #flash[:notice] = "Password mismatch" 
    end 
    #render :layout=>true
  rescue
    logger.error "Invalid Reset Code entered" 
    render :text=>"{success:false,
                      url:'/authorize/login',
                      notice:'Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?'}", :layout=>false
  end
  
  
end
