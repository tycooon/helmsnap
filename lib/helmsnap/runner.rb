# frozen_string_literal: true

class Helmsnap::Runner
  def self.call(...)
    new(...).call
  end

  def initialize(args)
    self.args = args.dup
  end

  def call
    parser = Helmsnap::ArgsParser.new(args)
    options = parser.get_options!

    cmd, *rest = args

    if cmd.nil?
      parser.print_help!("Command not provided.")
    end

    if rest.size.positive?
      parser.print_help!("Too many arguments.")
    end

    case cmd
    when "generate"
      Helmsnap::Generate.call(**options.to_h)
    when "check"
      Helmsnap::Check.call(**options.to_h)
    else
      parser.print_help!("Unknown command: #{cmd}.")
    end
  end

  private

  attr_accessor :args
end
