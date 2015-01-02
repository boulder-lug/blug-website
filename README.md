# Boulder Linux User Group Website

This is the static site generation for the [Boulder Linux User
Group](http://lug.boulder.co.us).

The site is generated and deployed with [middleman](http://middlemanapp.com/).

## Run the site locally

1. Install Ruby
2. Install Bundler `gem install bundler`
3. Install Everything Else `bundle install`
4. `middleman` && open browser

## Generate and view the site locally

1. `middleman build` (rebuild everything by adding `--clean`)
2. `heel -r build` -- this will launch a local web server and open your browser to it.

## Deploy to the website

1. You'll need to talk to make sure your ssh key is added to the servers
2. `middleman deploy`


