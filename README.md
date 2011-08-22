# Chatterbox
*A Simple Chat Server in Ruby*

Chatterbox is a dirt-simple and very naive chat server in Ruby.
It uses IO.select instead of threads, which means it is *event-driven*
and *sexy*. It runs in a single thread, but can still serve lots of
concurrent uses fairly quickly.

It has no protocol! It has no error handling! It is awesome!


## Useage

    require 'chatterbox'
    server = Chatterbox::Server.new
    # Chatterbox::Server.new can take several options,
    # including port and host, in a rails-like options hash.
    # Chatterbox::Server.new({:port => 13030, :host => "127.0.0.1" })
    # for example.
    server.start
    
    # Now make a few client sockets connect to it.
sock = TCPSocket.new
sock.connect("127.0.0.1", 13030)
sock.puts "\name Trogdor"
sock_other = TCPSocket.new
sock_other.connect(127.0.0.1", 13030)
sock_other.puts "\name Peasent"

