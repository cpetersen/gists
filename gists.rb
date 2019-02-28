#!/usr/bin/env ruby

require 'git'
require 'json'
require 'restclient'

gists = JSON.parse(RestClient.get('https://api.github.com/users/cpetersen/gists'))
gists.each do |gist|
  begin
    if File.exists? "#{gist["id"]}/.git"
      puts "Pulling... #{gist["html_url"]}"
      g = Git.open(gist["id"])
      g.pull
    else
      puts "Cloning... #{gist["html_url"]}"
      FileUtils.mkdir_p(gist["id"])
      Git.clone(gist["git_pull_url"], gist["id"])
    end
  rescue => e
    puts "Error on #{gist["html_url"]} [#{e.message}]"
  end
end; nil
