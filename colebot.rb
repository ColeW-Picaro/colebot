require 'rubygems'
require 'twitter'
require 'marky_markov'
require 'fiddle'

# unfreeze is the reverse of the freeze method.  It makes objects mutable
class Object
  def unfreeze
    Fiddle::Pointer.new(object_id * 2)[1] &= ~(1 << 3)
  end
end

def main

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  # This method gets all the tweets from a user's timeline, must only run once
  def get_all_tweets(user, markov)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: false}
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options).each do |tweet|
        parse_tweet(markov, tweet)
      end
    end
    return markov
  end

  # This method gets all tweets since a certain id
  def get_recent_tweets(user, markov, newest_id)
      options = {since_id: newest_id, include_rts: false}
      user_timeline(user, options).each do |tweet|
        parse_tweet(markov, tweet)
      end
    return markov
  end

  # This method puts a tweet into a markov chain and removes a t.co link
  def parse_tweet(markov, tweet)
    tweet = tweet.full_text
    tweet.unfreeze
    if tweet.include? "https:"
      tweet.slice!(/https:\/\/t.co\/\w{10}/)
    elsif tweet.include? "http:"
      tweet.slice!(/http:\/\/t.co\/\w{10}/)
    end
    markov.parse_string tweet
    return markov
  end

  # This method sends a tweet
  def send_tweet(client, markov)
    client.update(markov.generate_n_sentences 1)
  end

  # This method gets a user's newest tweet
  def get_newest_id(user)
    options = {count: 1, include_rts: false}
    tweet = user_timeline(user, options)
    return tweet[0].id
  end

 client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "your-token-here"
    config.consumer_secret     = "your-token-here"
    config.access_token        = "your-token-here"
    config.access_token_secret = "your-token-here"
  end

  #Create/Load dictionary.  Will save dictionary as usernameDictionary.mmd
  markov = MarkyMarkov::Dictionary.new(ARGV[1] + "Dictionary", 1)

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
