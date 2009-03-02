module AuthorizeHelper
  
    def ext_bloney_authorize_javascript_tags
      sources = %w(authorize_layout)  
      sources.collect do |source|
        source = javascript_path("bloney/authorize/"+source)
        content_tag("script","",{"type"=>"text/javascript","src"=>source})
        end.join("\n")
    end
    
  end