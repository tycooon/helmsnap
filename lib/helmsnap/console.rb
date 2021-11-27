# frozen_string_literal: true

module Helmsnap::Console
  extend self

  def print(stream, msg)
    stream.print(msg)
  end

  def info(stream, msg)
    msg = ColorizedString[msg].colorize(:light_yellow)
    stream.puts(msg)
  end

  def error(stream, msg)
    msg = ColorizedString[msg].colorize(:light_red)
    stream.puts(msg)
  end
end
