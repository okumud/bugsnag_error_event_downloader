# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class Option
    extend T::Sig

    attr_reader :option

    def initialize(args = ARGV)
      @option = {}
      args_tmp = args.dup
      args_tmp.each.with_index do |arg, i|
        if arg == "-t"
          @option[:token] = args_tmp[i + 1]
        else
          arg.start_with?("--token=")
          @option[:token] = arg.sub("--token=", "")
        end
      end
    end

    def has?(name)
      option.include?(name)
    end

    def get(name)
      option[name]
    end
  end
end
