=begin
  Filename: Main.rb
  Author: Cole Vohs
  Description: A script utilizing colebot.rb to maintain and utilize
  a markov chain dictionary with an authorized twitter account
=end

require_relative "colebot"
require "optparse"

def main
  # OAuth authentication from a file named oauth.txt
=begin
  oauth.txt looks like this:
  line 1: consumer key
  line 2: consumer secret
  line 3: access token
  line 4: access secret
  nothing beyond these lines matters
=end
  client = Twitter::REST::Client.new do |config|
    keys = []
    File.foreach ("oauth.txt") do |line|
      keys.push (line).gsub("\n", "")
    end
    config.consumer_key        = keys[0]
    config.consumer_secret     = keys[1]
    config.access_token        = keys[2]
    config.access_token_secret = keys[3]
  end

  # Process command line args
  # -u USER specifies a user
  # -d updates the user's dictionary
  # -r resets the user's dictionary
  # -t sends a tweet
  # -h prints help  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: Main.rb (-ud | -rd) (-t [OPTIONAL]) -u USER"

    opts.on("-d", "--update", "Update dictionary") do
      options[:update] = true
    end
    
    opts.on("-r", "--reset", "Reset dictionary") do
      option[:reset] = true
    end

    opts.on("-t", "--tweet", "Send a tweet") do
      options[:tweet] = true
    end
    
    opts.on("-uREQUIRED", "--user=REQUIRED USER", "Specify USER (required)") do |u|
      options[:user] = u
    end
    
    opts.on("-h", "--help", "Display help") do
      puts opts
      exit
    end
    
  end.parse!
  
  # Create/Load dictionary.  Will save dictionary as usernameDictionary.mmd
  if options.has_key?(:user)
    markov = MarkyMarkov::Dictionary.new(options[:user] + "Dictionary", 1)
  else
    puts "Error: Must provide user; use -h for help"
    abort
  end
  
  if (options[:reset])
    markov = client.get_all_tweets(options[:user], markov)
    markov.save_dictionary!
  elsif (options[:update])
    newest_id = client.get_newest_id(options[:user])
    markov = client.get_recent_tweets(options[:user], markov, newest_id)
    markov.save_dictionary!
  end
  
  if (options[:tweet])
      send_tweet(client, markov)
  end
end

main
