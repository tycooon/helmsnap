# frozen_string_literal: true

class Helmsnap::ArgsParser
  Args = Struct.new(:cmd, :chart_path, :snapshots_path, :values_path, keyword_init: true)
  MissingOption = Class.new(OptionParser::ParseError)

  def initialize(options)
    self.options = options
    self.args = build_default_args
    self.parser = build_parser
  end

  def get_options!
    parser.parse!(options)
    raise MissingOption, "missing option: VALUES" unless args.values
    args
  rescue OptionParser::ParseError => error
    puts error, nil
    print_help!
    exit 1
  end

  private

  attr_accessor :options, :parser, :args

  def build_parser
    OptionParser.new do |opts|
      opts.banner = "Usage: helmsnap CMD [options]"
      opts.separator("CMD should be either `generate` or `check`.")
      opts.separator("")
      opts.separator("Specific options:")

      opts.on("-v", "--values VALUES", "Values file") do |option|
        args.values_path = pn(option)
      end

      opts.on(*chart_path_cmd) do |option|
        args.chart_path = pn(option)
      end

      opts.on(*snapshots_path_cmd) do |option|
        args.snapshots_path = pn(option)
      end

      opts.on("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
  end

  def chart_path_cmd
    ["-c", "--chart-dir [DIR]", "Chart directory (default: #{args.chart_path})"]
  end

  def snapshots_path_cmd
    ["-s", "--snapshots-dir [DIR]", "Snapshots directory (default #{args.snapshots_path})"]
  end

  def print_help!
    puts parser.help
  end

  def build_default_args
    Args.new(
      chart_path: pn("k8s/chart"),
      snapshots_path: pn("k8s/snapshots"),
    )
  end

  def pn(...)
    Pathname.new(...)
  end
end
