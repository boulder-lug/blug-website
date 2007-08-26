require 'webby'

desc "Deploy to website"
task :deploy => :build do
    destination = "newcommunity:/home/httpd/lug.boulder.co.us/html"
    sh "rsync -zav --delete output/ #{destination}"
end