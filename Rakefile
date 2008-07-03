load 'tasks/setup.rb'

task :default => :build

desc 'depoloy the site to the webserver'
task :deploy => [:build, 'deploy:rsync']

SITE.user = "blug"
SITE.host = 'newcommunity.tummy.com'
SITE.remote_dir = '/home/httpd/lug.boulder.co.us/html'

