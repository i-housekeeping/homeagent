class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += ' Please activate your new account.  [do not reply]'
    @body[:url]  = "http://i-housekeeping.heroku.com/authorize/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += ' Your account has been activated! [do not reply]'
    @body[:url]  = "http://i-housekeeping.heroku.com"
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password [do not reply]'
    @body[:url]  = "http://i-housekeeping.heroku.com/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset [do not reply]'
  end
  
  def customeremail(params)
      @recipients  = params[:to_company]
      @from        = params[:from]
      @subject     = params[:subject]
      @sent_on     = Time.now
      @body        = params[:email_editor]
      @content_type= "text/html"

  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "i.housekeeping@gmail.com"
    @subject     = "i-Housekeeping Account Activation"
    @sent_on     = Time.now
    @body[:user] = user
  end
end
