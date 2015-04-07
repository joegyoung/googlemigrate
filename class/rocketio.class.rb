#!/usr/bin/env ruby

require 'sinatra/rocketio/client'



class WebSocket_RocketIO
  attr_accessor :students, :db
  def initialize(myname,channel='main')
    @myname = myname || 'Test2'
    #configuration = Yamlconfig::load("config.yml")
    hostname = $configuration["website"]["host"] || "localhost"
    @url = "http://#{hostname}:5000"
    @type =  :websocket
    @sleepsec = 1
    puts @myname
    @io = Sinatra::RocketIO::Client.new(@url, :type => @type, :channel => channel)
    @io.connect
    self
  end

  def send(message)

    #@io.connect
    name = @myname
    @io.push :chat, {:message => message, :name => name}
    #@io.on :connect do
      #puts "#{io.type} connect!! (session_id:#{io.session})"
     # @io.push :chat, {:message => message, :name => name}
    #end
    #sleep @sleepsec
    #@io.close
  end

def close
  @io.close
end

end

#WebSocketIO = WebSocket_RocketIO.new("tt")

#WebSocketIO.send("Line1")
#WebSocketIO.send("------ zAP")
#WebSocketIO.send("Line2")
#WebSocketIO.close