# frozen_string_literal: true

class Helmsnap::Runner < Helmsnap::Service
  def initialize(args)
    super()
    self.args = args.dup
  end

  def call
    parser = Helmsnap::ArgsParser.new(args)
    self.options = parser.get_options!
    self.config = Helmsnap::Config.new(options.config_path)

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

  attr_accessor :args, :options, :config

  def generate!
    Helmsnap::Generate.call(config)
    Helmsnap::Console.info($stdout, "Snapshots generated successfully.")
  end

  def check!
    if Helmsnap::Check.call(config)
      Helmsnap::Console.info($stdout, "Snapshots are up-to-date.")
    else
      example_cmd = Shellwords.join(["helmsnap", "generate", "--config", options.config_path])

      Helmsnap::Console.error(
        $stdout,
        "Snapshots are outdated. You should check the diff above and either fix your chart or " \
        "update the snapshots using the following command:\n> #{example_cmd}",
      )

      exit 1
    end
  end
end
