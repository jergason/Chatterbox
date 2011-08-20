require 'socket'

module Chatterbox
  class Server
    @@default_options = { :port => 3000, :address => "127.0.0.1" }

    def initialize(options = {})
      opts = @@default_options.merge(options)
      @port = opts[:port]
      @address = opts[:address]
      @server_socket = Socket.new(:INET, :STREAM)
      @server_socket.bind(Addrinfo.tcp(@address, @port))
      @server_socket.listen( 128 )
      @sockets = []
      @sockets << @server_socket
    end

    def run
      #TODO: use select to loop through sockets with data on them.
      #If the socket with data is the server_socket, then a new client
      #is connecting to us
      #Otherwise, it is a message from someone
      #Send notice to all other connected sockets
      loop do
        io, write, error = IO.select(@sockets, nil, nil, 10)
        #check IO for new stuff
        io.each do |sock|
          #if there is new stuff on the server socket, then someone new is trying to connect
          if sock == @server_socket
            new_sock = @server_socket.accept
            #TODO: get hostname from this socket, and broadcast it to all sockets?
            #TODO: broadcast its message? or wait until next time?
            @sockets << new_sock
          end
        end
      end
    end
  end
end
