require 'rubygems'
require 'twitter'
require 'marky_markov'

def main

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def get_all_tweets(user, markov)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: false}
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options).each do |tweet|
        parse_tweet(markov, tweet)
      end
      #new_tweet = markov.generate_n_sentences 1
      return markov
    end
  end

  def parse_tweet(markov, tweet)
    markov.parse_string tweet.full_text
    return markov
  end

  def send_tweet(client, markov)
    client.update(markov.generate_n_sentences 1)
  end

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "your_key_here"
    config.consumer_secret     = "your_key_here"
    config.access_token        = "your_key_here"
    config.access_token_secret = "your_key_here"
  end

  markov = MarkyMarkov::Dictionary.new('Dictionary', 1)

  markov = client.get_all_tweets("shoopRLB", markov)

  send_tweet(client, markov)

end

main
