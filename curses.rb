#!/usr/bin/env ruby

require 'curses'
include Curses


begin
  Curses.noecho # do not show typed keys
  Curses.cbreak
  Curses.init_screen
  Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
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
