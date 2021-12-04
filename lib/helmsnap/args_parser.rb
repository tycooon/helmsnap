# frozen_string_literal: true

class Helmsnap::ArgsParser
  Args = Struct.new(:config_path)

  DEFAULT_CONFIG_PATH = ".helmsnap.yaml"
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
  rescue OptionParser::ParseError => error
    print_help!(error)
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
        args.config_path = Pathname.new(val)
      end

      opts.on("--version", "Show version") do
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
