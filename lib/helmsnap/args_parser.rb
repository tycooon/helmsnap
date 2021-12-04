# frozen_string_literal: true

class Helmsnap::ArgsParser
  InvalidConfigPath = Class.new(RuntimeError)

  Args = Struct.new(:config_path)

  DEFAULT_CONFIG_PATH = Pathname.new(".helmsnap.yaml")
  CONFIG_PATH_HELP = %{Path to config (default: "#{DEFAULT_CONFIG_PATH}")}
  BANNER = "Usage: helmsnap CMD [options]"

  def initialize(options)
    self.options = options
    self.args = Args.new(DEFAULT_CONFIG_PATH)
    self.parser = build_parser
  end

  def get_options!
    parser.parse!(options)
    args
  rescue OptionParser::ParseError, InvalidConfigPath => error
    print_help!(error.message)
  end

  def print_help!(msg)
    Helmsnap::Console.error($stderr, "#{msg}\n") if msg
    Helmsnap::Console.print($stdout, parser.help)
    exit 1
  end

  private

  attr_accessor :options, :parser, :args

  def build_parser
    OptionParser.new(BANNER, 50) do |opts|
      opts.separator("Supported commands: `generate` and `check`.")
      opts.separator("")
      opts.separator("Specific options:")

      opts.on("-c", "--config CONFIG_PATH", CONFIG_PATH_HELP) do |val|
        path = Pathname.new(val)

        unless path.file? && path.readable?
          raise InvalidConfigPath, "Not a readable file: #{val}"
        end

        args.config_path = path
      end

      opts.on("-v", "--version", "Show version") do
        Helmsnap::Console.print($stdout, "#{Helmsnap::VERSION}\n")
        exit
      end

      opts.on("-h", "--help", "Show this message") do
        print_help!(nil)
        exit
      end
    end
  end
end
