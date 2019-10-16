#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'colorize'

def url_parser(url)
  host, path = url.split('/', 2)
  {
    host: host,
    path: path
  }
end

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
      puts(line[:description].green)
    else
      puts(line[:description])
    end
  end
end

host = 'gopherpedia.com'
port = 70
path = '/'

if !ARGV.empty?
  parsed_url = url_parser(ARGV.pop)
  host = parsed_url[:host]
  path = parsed_url[:path]
end

request = "#{path}\r\n"
response = request_maker(host, port, request)

parsed_response = response_parser(response)

display(parsed_response)

loop do
  print "\nCommand: "
  command = gets

  if command =~ /quit/ then
    puts 'Quitting...'
    break
  elsif command.start_with?('get ') then
    command.slice!('get ')
    parsed_url = url_parser(command.strip)
    host = parsed_url[:host]
    path = parsed_url[:path]
    request = "#{path}\r\n"
    response = request_maker(host, port, request)

    parsed_response = response_parser(response)

    display(parsed_response)
  else
    puts 'Did not understand.'
  end
end
