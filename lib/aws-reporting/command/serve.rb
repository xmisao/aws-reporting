module AwsReporting
  module Command
    module Serve
      def run(opts, args)
        begin
          help = opts['h']
          if help
            puts opts.help
            return
          end

          port = opts['port'] || 12345
          raise AwsReporting::Error::CommandArgumentError.new unless args.length == 1
          path = args[0]

          server = AwsReporting::Server.new(path, port)

          Signal.trap(:INT){
            server.stop
          }

          server.start
        rescue AwsReporting::Error::CommandArgumentError
          puts opts.help
        end
      end

      module_function :run
    end
  end
end
