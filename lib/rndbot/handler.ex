defmodule RndBot.Handler do
  def handle_privmsg(socket, [_, nick, user, ip, msg]) do
    IO.puts "#{nick}: #{msg}"
    case Enum.find(rand_regex_fns(), fn {regex, _} -> Regex.run(regex, msg) end) do
      {regex, fun} ->
        res = Regex.run(regex, msg)
        rn = fun.(res)
        (rn |> to_string()) |> (&(RndBot.Irc.privmsg(socket, nick, &1))).()
      _ ->
    end
  end

  defp rand_regex_fns do
    regex = ~r/rndbotrnd/
    regex_max = ~r/rndbotrnd[:]?\s+([1-9][0-9]*)/
    regex_min_max = ~r/rndbotrnd[:]?\s+([1-9][0-9]*)\-([1-9][0-9]*)/
    [{regex_min_max, fn [_, min, max] ->
       {mini, _} = Integer.parse(min)
       {maxi, _} = Integer.parse(max)
       RndBot.Random.rand(mini, maxi)
     end},
      {regex_max, fn [_, max] ->
        {maxi, _} = Integer.parse(max)
        RndBot.Random.rand(1, maxi)
      end},
      {regex, fn _ ->
        RndBot.Random.rand(1, 10)
      end}]
  end

  def handle_chanmsg(socket, [_, nick, user, ip, channel, msg]) do
    IO.puts "#{nick}@\##{channel}: #{msg}"
    case Enum.find(rand_regex_fns(), fn {regex, _} -> Regex.run(regex, msg) end) do
      {regex, fun} ->
        res = Regex.run(regex, msg)
        rn = fun.(res)
        ("#{nick}: " <> (rn |> to_string())) |> (&(RndBot.Irc.chanmsg(socket, channel, &1))).()
      _ ->
    end
  end
  
  def handle_irc_message(socket, message) do
    privmsg = ~r/:([^!]+)!~([^@]+)@([^\s]+)\sPRIVMSG\srndbotrnd\s:(.+)/
    chanmsg = ~r/:([^!]+)!~([^@]+)@([^\s]+)\sPRIVMSG\s\#([^\s]+)\s:(.+)/
    ping = ~r/PING:\s(.+)/

    regex_fns = [{privmsg, &(handle_privmsg(socket, &1))},
                 {chanmsg, &(handle_chanmsg(socket, &1))},
                  {ping, fn [_, from] ->
                    IO.puts "pong!"
                    RndBot.Irc.pong(socket, from)
                  end}]

    Enum.each regex_fns, fn {regex, fun} ->
      res = Regex.run(regex, message)
      if res != nil, do: fun.(res)
    end
  end

  def handle_command(socket, command) do
    case command do
      :quit ->
        RndBot.Irc.quit(socket)
      {:privmsg, nick, msg} ->
        RndBot.Irc.privmsg(socket, nick, msg)
      {:join, chan} ->
        RndBot.Irc.join(socket, chan)
      {:part, chan} ->
        RndBot.Irc.part(socket, chan)
      _ ->
        IO.puts "Unknown command!"
    end
  end
end
