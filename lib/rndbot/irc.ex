defmodule RndBot.Irc do
  def connect(server, port) do
    :gen_tcp.connect(server, port, [packet: 0, active: false])
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
