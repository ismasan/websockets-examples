# A channel keeps track of connected sockets and broadcasts events to all of them.
# Event format is JSON for:
#
# ['Socket-event_name', some_data]
#
# Where 'some_data' can be any valid JSON data type, so you can push your own messages:
#
# @channel.send_message :user_connected, :name => 'ismael', :bday => '29/11/77'
#
# Will send the following json object as a string that can be decoded by the clients:
#
# ['Socket-user_connected', {'name' : 'ismael', 'bday' : '29/11/77'}]
#
class Channel
  
  def initialize
    @subs = {}
  end
  
  def subscribe(user, ws)
    unsubscribe ws
    @subs[user] = ws
    notify_presence ws
    user
  end
  
  def unsubscribe(ws)
    @subs.delete user_for(ws)
    notify_presence ws
  end
  
  # Send raw text message to all subscribers
  def push(msg)
    @subs.values.each do |ws|
      ws.send(msg)
    end
  end
  
  # Send JSON encoded data, including sender user
  def send_message(event, from_ws, msg)
    push payload(event, from_ws, msg)
  end
  
  private
  
  def payload(event, from_ws, message)
    hash = {
      :from => user_for(from_ws)
    }
    if message.is_a?(Hash)
      hash.merge!(message)
    else
      hash[:data] = message
    end
    JSON.generate(["Socket-#{event}", hash])
  end
  
  def user_for(ws)
    puts @subs.inspect
    @subs.index(ws)
  end
  
  def notify_presence(from_ws)
    send_message(:presence, from_ws, :connections => @subs.size, :users => @subs.keys)
  end
end