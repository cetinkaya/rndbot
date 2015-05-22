RndBot
======

RndBot is an IRC bot that provides positive random numbers as replies to messages containing the text "rndbotrnd". The random numbers are obtained from random.org. 

### How to start the bot

It seems that the current easiest way is to first clone the repository with

```
git clone https://github.com/cetinkaya/rndbot.git
```

Then we install dependencies with

```
cd rndbot
mix deps.get
````

After that we can start the program in iex. To this end, first start iex:

```
iex -S mix
```

Then in iex, we start the bot with:

```
iex> bot = RndBot.Bot.start
```

Currently the bot automatically connects to chat.freenode.net and joins the channel #rndbottest. Commands can be sent to the bot inside iex to make it join other channels:

```
send bot, {:cmd, {:join, "otherchannel"}}
```

### What does rndbot do?

It provides random integers for a given range. For instance, when it sees a message "rndbotrnd 1-100", it returns a random integer (obtained from random.org) within the interval [1,100]. 
