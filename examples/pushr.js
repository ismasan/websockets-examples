// Ismael Celis 2010
var Pushr = function(channel, user){
  var conn = new WebSocket(Pushr.host + '/' + user);// channel later
  
  var callbacks = {};
  
  this.bind = function(event_name, callback){
    callbacks[event_name] = callbacks[event_name] || [];
    callbacks[event_name].push(callback);
    return this;//chainable
  };
  
  this.trigger = function(event_name, data){
    var payload = JSON.stringify([event_name, data]);
    Pushr.log(payload);
    conn.send(payload)
  };
  
  this.send = function(msg){
    this.trigger('message', msg);
  };
  
  // dispatch to the right handler
  conn.onmessage = function(evt){
    var data = eval(evt.data);
    var event_name = data[0].split('-')[1]; // message, other
    dispatch(event_name, data[1])
  };
  
  conn.onclose = function(){dispatch('close',null)}
  conn.onopen = function(){dispatch('open',null)}
  
  var dispatch = function(event_name, message){
    Pushr.log(arguments);
    var chain = callbacks[event_name];
    if(typeof chain == 'undefined'){
      Pushr.log('No callbacks for '+event_name);
      return;
    }
    for(var i=0;i<chain.length;i++){
      chain[i](message)
    }
  }
};
Pushr.host = "ws://localhost:8080";
Pushr.log = function(m){};