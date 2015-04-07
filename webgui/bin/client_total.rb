#!/usr/bin/env ruby

require 'sinatra/rocketio/client'


#require_relative "../../lib/functions.rb" 
require_relative "../../class/mongo.class.rb" 
require_relative "../../class/timer.class.rb" 

require 'mongo'
include Mongo




name = `whoami`.strip || 'shokai'
name = 'MR.01'
url = ARGV.shift || 'http://localhost:5000'
type = ARGV.shift || :websocket

io = Sinatra::RocketIO::Client.new(url, :type => type, :channel => "main").connect


io.on :connect do
  puts "#{io.type} connect!! (session_id:#{io.session})"
end

io.on :chat do |data|
 puts "<#{data['name']}> #{data['message']}"
end

io.on :error do |err|
  STDERR.puts err
end

io.on :disconnect do
  puts "disconnected!!"
end





loop do

  #sleep 5
  
  #line = STDIN.gets.strip
  #next if line.empty?
  #case line
  #  when /\\total:(.*)/
  #   io.push :total, {:message => $1, :name => name}
  #  else
  #    io.push :chat, {:message => line, :name => name}



end
