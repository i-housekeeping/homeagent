# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # JavaScript Collection of sources
  def ext_javascript_tags 
    sources = %w(ext-base ext-all-debug) 
    sources.collect do |source|
      source = javascript_path(source)
      content_tag("script","",{"type"=>"text/javascript","src"=>source})
    end.join("\n")
  end
  
  def ext_bloney_infra_javascript_tags
      sources = %w(bloney_infra )  
      sources.collect do |source|
        #source << "-min" if RAILS_ENV == "production"
        source = javascript_path("bloney/"+source)
        content_tag("script","",{"type"=>"text/javascript","src"=>source})
      end.join("\n")
  end
  
  def google_bloney_external_javascript_tags 
      sources = %w(http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAA1u4IWiwm4a4GMTWkXxLoRRi_j0U6kJrkFvY4-OX2XYmEAa76BSlsCk3366dQm7VxR6QL5Xo_Z5CEQ http://www.google.com/jsapi )    
      sources.collect do |source|
        content_tag("script","",{"type"=>"text/javascript","src"=>source})
      end.join("\n")
  end
  
  def ext_bloney_application_javascript_tags 
      sources = %w(bloney_notifications bloney_toolbar bloney_layout)  
      sources.collect do |source|
        #source << "-min" if RAILS_ENV == "production"
        source = javascript_path("bloney/"+source)
        content_tag("script","",{"type"=>"text/javascript","src"=>source})
      end.join("\n")
  end
  
  # CSS collection of sources
  def ext_stylesheet_tags
    sources = %w(ext-all.css xtheme-slate.css bloney.css)  
    sources.collect do |source|
      source = stylesheet_path(source)
      content_tag("link","",{"rel"=>"Stylesheet","type"=>"text/css",
                              "media"=>"screen","href"=>source})
    end.join("\n")
  end
  
end
