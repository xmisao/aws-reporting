module AwsReporting
  module Error
    class CommandArgumentError < StandardError; end
    class OverwriteError < StandardError
      attr_accessor :path
    end
    class ConfigFileLoadError < StandardError; end
  end
end
