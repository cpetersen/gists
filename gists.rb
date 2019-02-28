#!/usr/bin/env ruby

require 'git'
require 'json'
require 'restclient'

username = ARGV.first
puts "Getting gists for #{username}"

user_dir = "repos/#{username}"
FileUtils.mkdir_p(user_dir) unless File.exists?(user_dir)

page = 0
while true
  page+=1
  puts "Getting page #{page}..."
  gists = JSON.parse(RestClient.get("https://api.github.com/users/#{username}/gists?page=#{page}"))
  return if gists.empty?
  gists.each do |gist|
    repo_dir = "#{user_dir}/#{gist["id"]}"
    begin
      if File.exists? "#{repo_dir}/.git"
        puts "Pulling... #{gist["html_url"]}"
        g = Git.open(repo_dir)
        g.pull
      else
        puts "Cloning... #{gist["html_url"]}"
        Git.clone(gist["git_pull_url"], repo_dir)
      end
    rescue => e
      puts "Error on #{gist["html_url"]} [#{e.message}]"
    end
  end
end
