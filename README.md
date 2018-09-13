# colebot
A bot utilizing markov chain generation to generate tweets based on another account

### Usage
0. Install ruby and the required gems, which are listed at the top of the colebot.rb file

1. With a Twitter developer account (smh twitter you're killing your own site), create a new app and generate the tokens and keys.  Replace each key with the corresponding variable in the code and save the file.

2. run `ruby colebot.rb resetDictionary username` where `username` is your Twitter @.  This will create your dictionary in the same directory.

3. run `ruby colebot.rb sendTweet username` every time you want to update the dictionary and send a tweet.

4 BONUS STEP.  Schedule bot tweets using crontab.  Install crontab and type `crontab -e` and add the line `*/6 \* \* \* ruby ~/bots/colebot/colebot.rb sendTweet username'.  This will post a tweet every 6 hours. Type `man crontab` to learn more about how the scheduling works.

