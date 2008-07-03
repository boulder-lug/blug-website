# $Id$

begin
  require 'webby'
rescue LoadError
  require 'rubygems'
  require 'webby'
end

SITE = Webby.site

# Webby defaults
SITE.content_dir   = 'content'
SITE.output_dir    = 'output'
SITE.layout_dir    = 'layouts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn _darcs]
  
SITE.page_defaults = {
  'layout' => 'default'
}

# Items used to deploy the webiste
SITE.host       = 'blug@newcommunity.tummy.com'
SITE.remote_dir = '/home/httpd/lug.boulder.co.us/html'
SITE.rsync_args = %w( -av )

# Options passed to the 'tidy' program when the tidy filter is used
SITE.tidy_options = '-indent -wrap 80'

# Load the other rake files in the tasks folder
Dir.glob('tasks/*.rake').sort.each {|fn| import fn}

# EOF
