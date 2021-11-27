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
    self.options = parser.get_options!

    cmd, *rest = args

    if cmd.nil?
      parser.print_help!("Command not provided.")
    end

    if rest.size.positive?
      parser.print_help!("Too many arguments.")
    end

    case cmd
    when "generate"
      generate!
    when "check"
      check!
    else
      parser.print_help!("Unknown command: #{cmd}.")
    end
  end

  private

  attr_accessor :args, :options

  def generate!
    Helmsnap::Generate.call(**options.to_h)
    puts "Snapshots generated successfully."
  end

  def check!
    if Helmsnap::Check.call(**options.to_h)
      puts "Snapshots are up-to-date."
    else
      puts "Snapshots are outdated, you should check the diff above and either fix your chart or " \
           "update the snapshots using `helmsnap generate` command."
      exit 1
    end
  end
end
