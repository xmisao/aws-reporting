require 'webrick'

module AwsReporting
  class Server
    def initialize(path, port)
      @server = WEBrick::HTTPServer.new(:DocumentRoot => path, :Port => port, :BindAddress => "0.0.0.0")
    end

    def start()
      @server.start
    end

    def stop()
      puts 'server stopped.'
      @server.stop
    end
  end
end
