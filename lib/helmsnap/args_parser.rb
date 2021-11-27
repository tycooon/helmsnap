# frozen_string_literal: true

class Helmsnap::ArgsParser
  Args = Struct.new(:chart_path, :snapshots_path, :values_path, keyword_init: true)
  MissingOption = Class.new(OptionParser::ParseError)

  BANNER = "Usage: helmsnap CMD [options]"

  def initialize(options)
    self.options = options
    self.args = Args.new
    self.parser = build_parser
  end

  def get_options!
    parser.parse!(options)
    raise MissingOption, "Missing option: CHARTDIR" unless args.chart_path
    raise MissingOption, "Missing option: SNAPDIR" unless args.snapshots_path
    raise MissingOption, "Missing option: VALUES" unless args.values_path
    args
  rescue OptionParser::ParseError => error
    print_help!(error)
  end

  def print_help!(msg)
    puts msg, nil
    puts parser.help
    exit 1
  end

  private

  attr_accessor :options, :parser, :args

  def build_parser
    OptionParser.new(BANNER, 50) do |opts|
      opts.separator("Supported commands: `generate` and `check`.")
      opts.separator("")
      opts.separator("Specific options:")

      opts.on("-c", "--chart-dir CHARTDIR", "Chart directory") do |option|
        args.chart_path = pn(option)
      end

      opts.on("-s", "--snapshots-dir SNAPDIR", "Snapshots directory") do |option|
        args.snapshots_path = pn(option)
      end

      opts.on("-v", "--values VALUES", "Values file") do |option|
        args.values_path = pn(option)
      end

      opts.on("--version", "Show version") do
        puts Helmsnap::VERSION
        exit
      end

      opts.on("-h", "--help", "Show this message") do
        puts opts.help
        exit
      end
    end
  end

  def pn(...)
    Pathname.new(...)
  end
end
