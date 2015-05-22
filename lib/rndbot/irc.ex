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

defmodule RndBot.Irc do
  def connect(server, port) do
    :gen_tcp.connect(to_char_list(server), port, [packet: 0, active: false])
  end

  def isend(socket, msg) do
    :gen_tcp.send(socket, to_char_list(msg <> "\r\n"))
  end

  def irecv(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def pong(socket, to) do
    isend(socket, "PONG :#{to}")
  end

  def privmsg(socket, nick, msg) do
    isend(socket, "PRIVMSG #{nick} :#{msg}")
  end

  def chanmsg(socket, chan, msg) do
    isend(socket, "PRIVMSG \##{chan} :#{msg}")
  end

  def irecv_serve(socket, bot_server) do
    case irecv(socket) do
      {:ok, packet} -> 
        send(bot_server, {:irc, String.strip(to_string(packet))})
        irecv_serve(socket, bot_server)
      {:error, _} -> IO.puts "Error in irecv."
    end
  end

  def join(socket, chan) do
    isend(socket, "JOIN \##{chan}")
  end

  def part(socket, chan) do
    isend(socket, "PART \##{chan}")
  end
  
  def quit(socket) do
    isend(socket, "QUIT :have to go.")
    :gen_tcp.close(socket)
  end
end
