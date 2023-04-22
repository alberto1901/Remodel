#!/usr/local/bin/ruby

require File.dirname($0) + '/convert/model.rb'

ARGV.each do|a|
  puts "Argument: #{a}"
end

source, destination = ARGV

@plane = Model.new(source, destination);

@plane.save(@plane);

puts "That's all folks!"
