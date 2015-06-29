#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'kickscraper'
require 'json'

Kickscraper.configure do |config|
    config.email = ENV['KICKSTARTER_EMAIL']
    config.password = ENV['KICKSTARTER_PASSWORD']
end

slack_hook_credentials = ENV['SLACK_HOOK_CREDENTIALS']
project_slug = ENV['KICKSTARTER_PROJECT_SLUG']

def get_kickstarter_token
  Kickscraper.client
  Kickscraper.token
end

def get_kickstarter_project(project_slug, oauth_token)
  url = "https://api.kickstarter.com/v1/projects/#{project_slug}?oauth_token=#{oauth_token}"
  JSON.parse(HTTParty.get(url).body)
end


def goal_bar(p)
  progress_indicator = "•"

  goal_in_k = (p['goal'] / 1000).to_i
  current_in_k = (p['pledged'] / 1000)
  pre = progress_indicator * (current_in_k.round - 1)
  post = progress_indicator * (goal_in_k - current_in_k.round)
  
  "#{pre}$#{"%.1f" % current_in_k}k#{post}"
end

def post_to_slack(channel, text, slack_hook_credentials)
  slack_url = "https://hooks.slack.com/services/#{slack_hook_credentials}"
  HTTParty.post(slack_url,
    :body => {
      channel: channel,
      username: "Kickstarter Update",
      text: text
    }.to_json,
    :headers => {
      'Content-Type' => 'application/json'
    }
  )
end

def do_if_unchanged(key, value)
  cache_file_path = ENV['HOME'] + "/.do_if_unchanged_#{key}"
  prev_value = if File.exists?(cache_file_path)
    File.open(cache_file_path, "r:UTF-8").read
  else
    nil
  end

  if prev_value != value
    yield
    File.open(cache_file_path, "w:UTF-8") { |f| f.write(value) }
  end
end


p = get_kickstarter_project(project_slug, get_kickstarter_token())
text = "#{goal_bar(p)} - #{p['currency_symbol']}#{"%.2f" % p['pledged']} pledged from #{p['backers_count']} backers."

do_if_unchanged("kickstarter_status", text) {
  ENV['SLACK_CHANNELS'].split(' ').each { |channel|
    post_to_slack(channel, text, slack_hook_credentials)
  }
}
