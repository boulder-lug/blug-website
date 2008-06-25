load 'tasks/setup.rb'

task :default => :build

desc 'depoloy the site to the webserver'
task :deploy => [:build, 'deploy:rsync']

# Options passed to the 'tidy' program when the tidy filter is used
SITE.tidy_options = '-indent -wrap 80'

SITE.user = "blug"
SITE.host = "newcommunity.tummy.com"
SITE.remote_dir = '/home/httpd/lug.boulder.co.us/html'
SITE.rsync_args = %w( -av )


