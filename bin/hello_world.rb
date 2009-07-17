#!/usr/bin/ruby

require 'rubygems'
require 'techtrovert/job_group'

class MainClass

  def self.main(args)
    puts "Main process running.  PID: #{Process.pid}"
    puts

    message = "Hello World!"

    jgroup = Techtrovert::JobGroup.new

    job_id = jgroup.add(message) do |m|
      puts "  Job running.  PID: #{Process.pid}"
      puts m
      puts
    end

    jgroup.run

  end

  # kick off execution
  main(ARGV)
end

    

