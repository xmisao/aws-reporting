module AwsReporting
  module Command
    module Config
      DEFAULT_PATH = '~/.aws-reporting/config.yaml'
      MESSAGE_ALREADY_EXIST = " already exists. If you want to overwrite this, use '-f' option."

      def run(opts, args)
        Signal.trap(:INT){
          puts
          puts "interrupted."
          exit
        }

        help = opts['h']
        if help
          puts opts.help
          return
        end

        begin
          access = opts['access-key-id']
          secret = opts['secret-access-key']
          force = opts['f']

          if access and secret
            run_batch(access, secret, force)
          elsif !!!access and !!!secret
            run_interactive(force)
          else
            raise CommandArgumentError.new
          end
        rescue AwsReporting::Error::CommandArgumentError
          puts opts.help
        end
      end

      def run_batch(access, secret, force)
        path = File.expand_path(DEFAULT_PATH)
        if force or !File.exist?(path)
          update_config(access, secret, path)
          puts 'done.'
        else
          puts path + MESSAGE_ALREADY_EXIST
        end
      end

      def run_interactive(force)
        path = File.expand_path(DEFAULT_PATH)
        if force or !File.exist?(path)
          print 'Access Key ID    :'
          access = $stdin.gets.chomp
          print 'Secret Access Key:'
          secret = $stdin.gets.chomp

          update_config(access, secret, path)
          puts 'done.'
        else
          puts path + MESSAGE_ALREADY_EXIST
        end
      end

      def update_config(access, secret, path)
        yaml = YAML.dump(:access_key_id => access, :secret_access_key => secret)

        FileUtils.mkdir_p(File.dirname(path))

        open(path, 'w'){|f|
          f.print yaml
        }
      end

      module_function :run, :run_batch, :run_interactive, :update_config
    end
  end
end
