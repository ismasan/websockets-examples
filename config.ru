require 'rubygems'
require 'rack'

use Rack::Static, :urls => ["/examples"]

use Rack::ShowExceptions

app = lambda { |env| 
  [200, {'Content-Type' => 'text/plain'}, 'OK'] 
}

run app