# Copyright 2015 Ahmet Cetinkaya

# This file is part of RndBot.

# RndBot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# RndBot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with RndBot.  If not, see <http://www.gnu.org/licenses/>.

defmodule RndBot.Handler do
  def handle_privmsg(socket, [_, nick, _user, _ip, _bot_nick, msg]) do
    IO.puts "#{nick}: #{msg}"
    case Enum.find(rand_regex_fns(), fn {regex, _} -> Regex.run(regex, msg) end) do
      {regex, fun} ->
        res = Regex.run(regex, msg)
        rn = fun.(res)
        (rn |> to_string()) |> (&(RndBot.Irc.privmsg(socket, nick, &1))).()
      _ -> nil
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

  def handle_chanmsg(socket, [_, nick, _user, _ip, channel, msg]) do
    IO.puts "#{nick}@\##{channel}: #{msg}"
    case Enum.find(rand_regex_fns(), fn {regex, _} -> Regex.run(regex, msg) end) do
      {regex, fun} ->
        res = Regex.run(regex, msg)
        rn = fun.(res)
        ("#{nick}: " <> (rn |> to_string())) |> (&(RndBot.Irc.chanmsg(socket, channel, &1))).()
      _ -> nil
    end
  end
  
  def handle_irc_message(socket, message) do
    privmsg = ~r/^:([^!]+)!~([^@]+)@([^\s]+)\sPRIVMSG\s([^\#\s]+)\s:(.+)$/
    chanmsg = ~r/^:([^!]+)!~([^@]+)@([^\s]+)\sPRIVMSG\s\#([^\s]+)\s:(.+)$/
    ping = ~r/^PING\s:(.+)$/

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
      _ -> nil
        IO.puts "Unknown command!"
    end
  end
end
