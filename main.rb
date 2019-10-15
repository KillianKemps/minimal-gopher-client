#!/usr/bin/env ruby

require 'socket'
require 'timeout'

host = 'gopherpedia.com'
port = 70
path = '/'
request = "#{path}\r\n"

begin
  Timeout.timeout(3) do
    socket = TCPSocket.open(host, port)
    socket.print(request)
    response = socket.read
    socket.close
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

      puts(parsed_line[:description])
    end
  end
rescue Timeout
  puts 'timed out!'
end
