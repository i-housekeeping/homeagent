# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require "css_http_request"
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '027015d63e5d3b4261b94f030ca777ab'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def post_directory(params)
    
    #if(params[:share].eql? "true")
      #Posted on Bloney Cashflow site  everybody could see it
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/#{params[:folder_name]}")
      File.open("#{RAILS_ROOT}/db/shared/#{params[:folder_name]}/#{params[:file_name]}.yml", 'w') { |f| f.write(yield) }
    #else
      #Posted on company site soe everybody could see it
      #key = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{session[:company].customer_name}--")
      
      #FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/customers")
      #File.open("#{RAILS_ROOT}/db/shared/customers/#{session[:company].customer_name}_#{key}.yml", 'w') {|f| f.write(customers.to_yaml) }
      
      #params[:from] = "admin@bloney.co.cc"
      #params[:to_company] = Customer.find(:first,:conditions=>"customer_name='#{params[:expert_name]}'")[:email]
      #params[:subject] = "Customers Directory"
      #params[:email_editor] = "#{session[:company].customer_name} customers directory is available for your usage. Activation key is :#{key} "
      #UserNotifier.deliver_customeremail(params)
    #end
    
  end
end
