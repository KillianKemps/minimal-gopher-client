#!/usr/bin/env ruby

require 'curses'
include Curses

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

begin
  Curses.noecho # do not show typed keys
  Curses.cbreak
  Curses.init_screen
  Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
  Curses.stdscr.scrollok true
  Curses.start_color
  # Determines the colors in the 'attron' below
  Curses.init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLACK) 
  Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_BLACK)

  y_pos = 0

  loop do

    case Curses.getch

    when Curses::Key::PPAGE
      y_pos -= 1 if y_pos > 0
      Curses.clear
      Curses.setpos(y_pos, 0)
      # Use colors defined color_init
      Curses.attron(color_pair(COLOR_BLUE)|A_NORMAL){
        Curses.addstr("Page Up #{y_pos}")
      }
      Curses.refresh
    when Curses::Key::NPAGE
      y_pos += 1 if y_pos < Curses.lines - 1
      Curses.clear
      Curses.setpos(y_pos, 0)
      Curses.attron(color_pair(COLOR_RED)|A_NORMAL){
        Curses.addstr("Page Down #{y_pos}")
      }
      Curses.refresh
    when Curses::Key::UP
      Curses.scrl(1) # scrolls up one line
      Curses.refresh
    when Curses::Key::DOWN
      Curses.scrl(-1) # scrolls down one line
      Curses.refresh
    when 'l'
      Curses.clear
      Curses.setpos(0, 0)
      response = `echo '/' | nc #{ARGV[0] || 'gopherpedia.com'} 70`
      parsed_response = response_parser(response)
      Curses.attron(color_pair(COLOR_RED)|A_NORMAL){
        parsed_response.each do |line|
          Curses.addstr(line[:description] + "\n")
        end
      }
      Curses.refresh
    when 27, 'q'
      Curses.clear
      Curses.setpos(Curses.lines - 1, 2)
      Curses.attron(color_pair(COLOR_RED)|A_NORMAL){
        Curses.addstr("Quitting...")
      }
      Curses.refresh
      sleep(1)
      break
    end
  end
ensure
  Curses.close_screen
end
