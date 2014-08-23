module AwsReporting
  module Command
    module Version
      def run(opts, args)
        puts AwsReporting::Version.get
      end

      module_function :run
    end
  end
end
