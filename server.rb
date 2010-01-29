require 'rubygems'
require 'em-websocket'
require 'json'

Dir['./lib/*.rb'].each {|f| puts f;require f}


EventMachine.run {
  
  @channel = Channel.new
  
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen {
      user = ws.request['Path'].gsub('/','')
      @sid = @channel.subscribe(user, ws)
      @channel.send_message :user_connected, ws, "connected!"
    }
    
    ws.onmessage { |msg|
      event_type, data = JSON.parse(msg)
      @channel.send_message event_type, ws, data
    }
    
    ws.onclose {
      @channel.unsubscribe(ws);
      @channel.send_message :user_disconnected, ws, "disconnected!"
    }
    puts 'Server started'
  end
}