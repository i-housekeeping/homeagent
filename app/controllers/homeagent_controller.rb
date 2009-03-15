class HomeagentController < ApplicationController
  
  def index
    logger.warn "Request: #{request}"
    redirect_to "http://www.i-housekeeping.co.cc/", :layout=>false
    #render :text=>"TEST"
  end
end
