
require 'ostruct'

SITE = OpenStruct.new

SITE.content_dir   = 'content'
SITE.output_dir    = 'output'
SITE.layout_dir    = 'layouts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn]
  
SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

SITE.host       = 'blug@newcommunity.tummy.com'
SITE.remote_dir = '/home/httpd/lug.boulder.co.us/html'
SITE.rsync_args = %w(-av --dry-run)

FileList['tasks/*.rake'].each {|task| import task}

%w(heel).each do |lib|
  Object.instance_eval {const_set "HAVE_#{lib.upcase}", try_require(lib)}
end

# EOF
