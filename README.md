# colebot 1.1 - New features on the way
Twitter hates fun and won't let me make new bots, so I'm just gonna make this one do cool stuff.

## Features
1. Utilizing markov chain generation to generate tweets based on another account
2. Generating a random vape flavor (see vapeflavor repo (or don't))
3. idk yet (pictures probably soon when I can sort that out)

### Usage
0. Clone this repo and run `bundle install` to install required gems and compile modules

1. With a Twitter developer account (smh twitter you're killing your own site), create a new app with read, write, and access direct messages permissions and generate the tokens and keys. Create a text file named "oauth.txt" and put your keys in the file in the following order: consumer key, consumer secret, access token, access secret.

2. run `ruby Main.rb -h` to display usage and help

3. BONUS STEP.  Schedule bot tweets using crontab.  Install crontab and type `crontab -e` and add the line `0 */6 * * * ruby /dir/to/Main.rb -d -t -u USER -a /dir/to/oauth.txt -i /path/to/dictionary`.  This will update the dictionary and post a tweet every 6 hours. Type `man crontab` to learn more about how the scheduling works.

