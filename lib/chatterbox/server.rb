require 'socket'

module Chatterbox
  class Server
    @@default_options = { :port => 13000,
                          :address => "127.0.0.1",
                          :msg_length => 10000 }

    def initialize(options = {})
      opts = @@default_options.merge(options)
      @port = opts[:port]
      @address = opts[:address]
      @msg_length = opts[:msg_length]
      @server_socket = Socket.new(:INET, :STREAM)
      @server_socket.bind(Addrinfo.tcp(@address, @port))
      @server_socket.listen( 128 )
      @sockets = []
      @sockets << @server_socket
      @names = {}
      @default_name_index = 1
    end

    def run
      #TODO: use select to loop through sockets with data on them.
      #If the socket with data is the server_socket, then a new client
      #is connecting to us
      #Otherwise, it is a message from someone
      #Send notice to all other connected sockets
      loop do
        io, write, error = IO.select(@sockets, nil, nil, 10)
        puts "got some stuff from SELECT"
        next if io.nil?
        #check IO for new stuff
        io.each do |sock|
          # If there is new stuff on the server socket, then someone new is trying to connect.
          if sock == @server_socket
            new_sock, new_address = @server_socket.accept
            puts "GOT A NEW SOCKET CONNECTION! #{new_sock}"
            #TODO: get hostname from this socket, and broadcast it to all sockets?
            #TODO: broadcast its message? or wait until next time?
            @sockets << new_sock
            @names[new_sock] = "masked_avenger_#{@default_name_index}"
            @default_name_index = @default_name_index + 1
          # Someone is posting a message to the chat server
          else
            msg, address = sock.recvfrom(@msg_length)
            puts "msg is #{msg}"
            if msg =~ /\\quit|\\exit/i
              write_to_all_except(sock, "#{@names[sock]} has left the chat.")
              sock.close
              @sockets.delete sock
              @names.delete sock
            elsif msg =~ /\\name[\s+](.*)/
              # TODO: get the name change
              old_name = @names[sock]
              @names[sock] = new_name
              write_to_all_except(sock, "#{old_name} changed their name to #{new_name}.")
            else
              write_to_all_except(sock, "#{@names[sock]}: #{msg}")
            end
          end
        end
      end
    end

    def write_to_all_except(sock, message)
      @sockets.reject {|s| s == sock or s == @server_socket }.each do |s|
        s.puts(message)
      end
    end

  end
end
