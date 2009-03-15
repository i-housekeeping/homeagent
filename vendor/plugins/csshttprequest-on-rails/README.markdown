# CSSHttpRequest is cross-domain AJAX using CSS.
# CSSHttpRequest On Rails is a plugin that allows you to generate CHR responses

Install the plugin as a gem or from the git url.

After installing, you can send CHR responses from your Rails app a few different ways

Serialize an object to JSON:

    render :chr => {:text => @sample_data.to_json}
    
The :chr key takes the normal render options hash as its value.
    
Or, if you include these lines in `config/initializers/mime_types.rb`,
    
    Mime::Type.register_alias "text/css", :chr, ['css-http']
    Mime::Type.register_alias "text/css", :jsonc, ['css-json']
    
you can render using custom response formats from their own templates:

    respond_to do |format|
      format.chr { }    #=> renders the <action_name>.chr template
      format.jsonc { }  #=> renders the evaluated Ruby object in <action_name>.jsonc as CHR encoded JSON
    end


## Patch Me!

Fork this repo, make it work better for you and your app. Send us a pull request.
We'll love you forever, and totally pimp your site and your skills.


## CSSHttpRequest Info

### Please see the latest info at [http://nb.io/hacks/csshttprequest/](http://nb.io/hacks/csshttprequest/)

Like JavaScript includes, this works because CSS is not subject to the
same-origin policy that affects XMLHttpRequest. CSSHttpRequest functions
similarly to JSONP, and is limited to making GET requests. Unlike JSONP,
untrusted third-party JavaScript cannot execute in the context of the calling
page.

The transport encodes the payload in the background-image property:

    #c0 { background: url(data:,Hello%20World!); }

This version has been tested in cross-domain contexts in Safari 3.x, Firefox 3.x
and Internet Explorer 6.

Copyright (c) 2009 Cameron Walters, released under the MIT license
