RndBot
======

RndBot is an IRC bot that provides positive random numbers as replies to messages containing the text "rndbotrnd". The random numbers are obtained from random.org. 

### How to install and start the bot

It seems that the current easiest way of installation is cloning the repository:

```
git clone https://github.com/cetinkaya/rndbot.git
```

After that we need to install the dependencies with Mix (which comes with Elixir):

```
cd rndbot
mix deps.get
````

We can then start the program in iex. To do that, first start iex:

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

### What does RndBot do?

It provides random integers for a given range. For instance, when it sees a message "rndbotrnd 1-100", it returns a random integer (obtained from random.org) within the interval [1,100]. 
