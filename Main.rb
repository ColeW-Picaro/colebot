=begin
  Filename: Main.rb
  Author: Cole Vohs
  Description: A script utilizing colebot.rb to maintain and utilize
  a markov chain dictionary with an authorized twitter account
=end

require_relative "colebot"

def main
  # OAuth authentication
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
  
  # Create/Load dictionary.  Will save dictionary as usernameDictionary.mmd
  markov = MarkyMarkov::Dictionary.new(ARGV[1] + "Dictionary", 1)
  
  # Process command line arguments, resetDictionary to make a dictionary
  # sendTweet to actually send a tweet
  if ARGV[0] == "resetDictionary"
    markov = client.get_all_tweets(ARGV[1], markov)
    markov.save_dictionary!
  elsif ARGV[0] == "sendTweet"
    newest_id = client.get_newest_id(ARGV[1])
    markov = client.get_recent_tweets(ARGV[1], markov, newest_id)
    markov.save_dictionary!
    send_tweet(client, markov)
  end
end

main
