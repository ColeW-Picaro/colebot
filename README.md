# colebot
A bot utilizing markov chain generation to generate tweets based on another account

### Usage
0. Clone this repo and run `bundle install` to install required gems

1. With a Twitter developer account (smh twitter you're killing your own site), create a new app with read, write, and access direct messages permissions and generate the tokens and keys. Create a text file named "oauth.txt" and put your keys in the file in the following order: consumer key, consumer secret, access token, access secret.

2. run `ruby Main.rb -h` to display usage and help

3. BONUS STEP.  Schedule bot tweets using crontab.  Install crontab and type `crontab -e` and add the line `0 */6 * * * ruby /dir/to/Main.rb -d -t -u USER -a /dir/to/oauth.txt -i /path/to/dictionary`.  This will update the dictionary and post a tweet every 6 hours. Type `man crontab` to learn more about how the scheduling works.

