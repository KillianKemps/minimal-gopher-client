#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'colorize'

host = 'gopherpedia.com'
host = 'khzae.net'
port = 70
path = '/'
request = "#{path}\r\n"

def request_maker(host, port, request)
  begin
    Timeout.timeout(3) do
      socket = TCPSocket.open(host, port)
      socket.print(request)
      response = socket.read
      socket.close
      return response
    end
  rescue Timeout
    puts 'timed out!'
  end
end

def response_parser(response)
  lines = response.split("\n")

  # Handle the final dot if it is there
  if lines[-1].strip == "." then
    lines = lines[0..-2]
  end

  parsed_lines = []

  lines.each do |line|
    type = line.slice!(0)

    # Skip lines with \r
    next if type == "\r"

    splitted_line = line.split("\t")

    parsed_line = {
      type: type,
      description: splitted_line[0],
      path: splitted_line[1],
      host: splitted_line[2],
      port: splitted_line[3].to_i
    }

    parsed_lines << parsed_line
  end

  parsed_lines
end

def display(parsed_response)
  parsed_response.each do |line|
    if line[:path] != '' then
      puts(line[:description].blue)
    else
      puts(line[:description])
    end
  end
end

response = request_maker(host, port, request)

parsed_response = response_parser(response)

display(parsed_response)
