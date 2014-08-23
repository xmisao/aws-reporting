module AwsReporting
  module Command
    module Run
      MESSAGE_ALREADY_EXIST = " already exists. If you want to overwrite this, use '-f' option."

      def run(opts, args)
        begin
          help = opts['h']
          if help
            puts opts.help
            return
          end

          force = opts['f']
          raise AwsReporting::Error::CommandArgumentError.new unless args.length == 1
          path = args[0]

          generator = AwsReporting::Generator.new
          generator.path = path
          generator.force = force
          generator.generate
        rescue AwsReporting::Error::CommandArgumentError
          puts opts.help
        rescue AwsReporting::Error::OverwriteError => e
          puts e.path + MESSAGE_ALREADY_EXIST
        end
      end

      module_function :run
    end
  end
end
