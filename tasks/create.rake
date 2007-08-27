
require 'webby'

Rake::WebbyTask.new do |webby|
  webby.deploy_to     = "newcommunity:/home/httpd/lug.boulder.co.us/html"
end

