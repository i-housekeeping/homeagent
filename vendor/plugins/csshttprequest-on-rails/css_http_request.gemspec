Gem::Specification.new do |s|
  s.name = 'css_http_request'
  s.version = '0.1'
  s.date = '2009-01-09'
  s.summary = "CSSHttpRequest is cross-domain AJAX using CSS"
  s.email = 'ping@nb.io'
  s.homepage = 'http://nb.io/hacks/csshttprequest/'
  s.description = "Like JavaScript includes, this works because CSS is not subject to the same-origin policy that affects XMLHttpRequest. CSSHttpRequest functions similarly to JSONP, and is limited to making GET requests. Unlike JSONP, untrusted third-party JavaScript cannot execute in the context of the calling page."
  s.has_rdoc = true
  s.authors = ['Cameron Walters', 'Randy Reddig']
  s.files = [
    "MIT-LICENSE",
    "Manifest.txt",
    "README.markdown",
    "Rakefile",
    "css_http_request.gemspec",
    "init.rb",
    "install.rb",
    "lib/css_http_request.rb",
    "lib/css_http_request_ext.rb",
    "lib/css_http_request_handler.rb",
    "rails/init.rb",
  ]
  s.test_files = [
    "test/css_http_request_test.rb",
    "test/test_helper.rb",
  ]
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["README.markdown"]
  s.add_dependency 'rails', ['>= 2.1']
end

