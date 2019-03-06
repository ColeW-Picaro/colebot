=begin
  Filename: colebot.rb
  Author: Cole Vohs (some functions taken from twitter gem wiki and stack overflow)
  Description: colebot.rb contains the functions required to host a twitter bot
=end

require "rubygems"
require "twitter"
require "marky_markov"
require "fiddle"

# unfreeze is the reverse of the freeze method.  It makes objects mutable
# Taken from https://stackoverflow.com/questions/35633367/how-to-unfreeze-an-object-in-ruby
# Flips the 11th bit in an object, which is is the FL_FREEZE flag in an object. Really janky, but w/e
class Object
  def unfreeze
    Fiddle::Pointer.new(object_id * 2)[1] &= ~(1 << 3)
  end
end

# Global function definitions
public

# returns the max id of a timeline
# Taken from https://github.com/sferik/twitter/blob/master/examples/AllTweets.md
def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

# This method gets all the tweets from a user's timeline and returns a dictionary of them, must only run once
# Adapted from https://github.com/sferik/twitter/blob/master/examples/AllTweets.md
def get_all_tweets(user)
  tweets = []
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: false}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options).each do |tweet|
      tweets.push(tweet)
    end
  end
  return tweets
end

# This method gets all tweets since a certain id
def get_recent_tweets(user, newest_id)
  options = {since_id: newest_id, include_rts: false}
  tweets = []
  user_timeline(user, options).each do |tweet|
    tweets.push(tweet)
  end
  return tweets
end

# This method puts each tweet into a markov chain and removes all links and @s
# Removing links might be undesired in some cases, but marky_markov's implmentation
# makes them difficult to handle because they contain periods.
def parse_tweets(markov, tweets)
  tweets.each do |tweet|
    text = tweet.full_text
    text.unfreeze
    text = text.gsub(/(http:\/\/|https:\/\/)\w+/, "")
    text = text.gsub(/@\w+/, "")
    markov.parse_string(text)
  end
  return markov
end

# This method gets a tweet from the dictionary of depth 1 and sends it
def send_tweet(client, tweet)
  client.update(tweet)
end

# This method gets a user's newest tweet
def get_newest_id(user)
  options = {count: 1, include_rts: false}
  tweet = user_timeline(user, options)
  return tweet[0].id
end
