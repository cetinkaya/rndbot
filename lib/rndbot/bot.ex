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

defmodule RndBot.Bot do
  def bot_serve(socket) do
    receive do
      {:irc, message} -> RndBot.Handler.handle_irc_message(socket, message)
      {:cmd, command} -> RndBot.Handler.handle_command(socket, command)
    end
    bot_serve(socket)
  end

  def start(server \\ "chat.freenode.net", nick \\ "rndbotrnd") do
    {:ok, socket} = RndBot.Irc.connect(server, 6667)
    RndBot.Irc.isend(socket, "NICK #{nick}")
    RndBot.Irc.isend(socket, "USER #{nick} * * :#{nick}")
    RndBot.Irc.isend(socket, "JOIN #rndbottest")
    bot_server = spawn fn -> bot_serve(socket) end
    spawn fn -> RndBot.Irc.irecv_serve(socket, bot_server) end
    bot_server
  end
end
