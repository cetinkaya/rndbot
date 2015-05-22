defmodule RndBot.Bot do
  def bot_serve(socket) do
    receive do
      {:irc, message} -> RndBot.Handler.handle_irc_message(socket, message)
      {:cmd, command} -> RndBot.Handler.handle_command(socket, command)
    end
    bot_serve(socket)
  end

  def start do
    {:ok, socket} = RndBot.Irc.connect('chat.freenode.net', 6667)
    nick = "rndbotrnd"
    RndBot.Irc.isend(socket, "NICK #{nick}")
    RndBot.Irc.isend(socket, "USER #{nick} * * :#{nick}")
    RndBot.Irc.isend(socket, "JOIN #rndbottest")
    bot_server = spawn fn -> bot_serve(socket) end
    spawn fn -> RndBot.Irc.irecv_serve(socket, bot_server) end
    bot_server
  end
end
