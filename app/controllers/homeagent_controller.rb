class HomeagentController < ApplicationController
  
  def index
    logger.warn "Request: #{request}"
    #redirect_to "http://i-housekeeping.servehttp.com:3001", :layout=>false
    render :text=>"TEST"
  end
end
