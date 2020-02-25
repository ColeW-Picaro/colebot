=begin
  Filename: Main.rb
  Author: Cole Vohs
  Description: A script utilizing colebot.rb to maintain and utilize
  a markov chain dictionary with an authorized twitter account
=end

require_relative "colebot"
require "optparse"

def main
  # Process command line args
  # -u USER specifies a user
  # -d updates the user's dictionary
  # -r resets the user's dictionary
  # -t sends a tweet
  # -v tweets a vape flavor
  # -h prints help  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: Main.rb (-ud | -rd) (-t [OPTIONAL]) -u USER"

    opts.on("-d", "--update", "Update dictionary") do
      options[:update] = true
    end
    
    opts.on("-r", "--reset", "Reset dictionary") do
      options[:reset] = true
    end

    opts.on("-t", "--tweet", "Send a tweet") do
      options[:tweet] = true
    end
    
    opts.on("-uREQUIRED", "--user=REQUIRED USER", "Specify USER (required)") do |u|
      options[:user] = u
    end

    opts.on("-v", "--vape", "send vape flavor") do
      options[:vape] = true
    end
    
    opts.on("-aREQUIRED", "--auth=REQUIRED AUTH", "Specify AUTH file (required") do |a|
      options[:auth] = a
    end

    opts.on("-i", "--dict DICT", "Specify dictionary DICT (default is current dirctory)") do |i|
      options[:dictionary] = i.gsub(".mmd", "")

    end
    
    opts.on("-h", "--help", "Display help") do
      puts opts
      exit
    end
    
  end.parse!

  # OAuth authentication from a file named oauth.txt
  # oauth.txt looks like this:
  # line 1: consumer key
  # line 2: consumer secret
  # line 3: access token
  # line 4: access secret
  # nothing beyond these lines matters

  client = Twitter::REST::Client.new do |config|
    keys = []
    File.foreach (options[:auth]) do |line|
      keys.push (line).gsub("\n", "")
    end
    config.consumer_key        = keys[0]
    config.consumer_secret     = keys[1]
    config.access_token        = keys[2]
    config.access_token_secret = keys[3]
  end

  
  # Create/Load dictionary.  Will save dictionary as usernameDictionary.mmd
  if options.has_key?(:user)
    if options.has_key?(:dictionary)
      markov = MarkyMarkov::Dictionary.new(options[:dictionary], 1)
    else
      markov = MarkyMarkov::Dictionary.new(options[:user] + "Dictionary", 1)
    end
  else
    puts "Error: Must provide user; use -h for help"
    abort
  end

  # If the reset flag is set, reset the dictionary,
  # If the update flag is set, update the dictionary,
  # else do nothing
  if (options[:reset])
    tweets = client.get_all_tweets(options[:user])
    parse_tweets(markov, tweets)
    markov.save_dictionary!
  elsif (options[:update])
    newest_id = client.get_newest_id(options[:user])
    tweets = client.get_recent_tweets(options[:user], newest_id)
    parse_tweets(markov, tweets)
    markov.save_dictionary!
  end

  # Vape Flavor module
  # Run the vapeflavor program and use the output file flavor.txt
  # Module stored in modules/vapeflavor
  if (options[:vape])
    `./modules/vapeflavor/Flavor`
    flavor = IO.readlines("modules/vapeflavor/flavor.txt")
    tweet = "Vape Flavor: " + flavor[0]
    send_tweet(client, tweet)
  end

  # Tweet if the user asked
  if (options[:tweet])
    send_tweet(client, markov.generate_n_sentences(1))
  end
end

main
