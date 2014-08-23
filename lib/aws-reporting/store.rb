module AwsReporting
  module Store
    class Counter
      def initialize
        @counter = 0
        @mutex = Mutex.new
      end

      def get
        @mutex.synchronize{
          @counter += 1
          return @counter
        }
      end
    end

    FILE_COUNTER = Counter.new

    def save(dir, data)
      FileUtils.mkdir_p(dir)

      path = dir + '/' + FILE_COUNTER.get.to_s + '.json'

      json = JSON.dump(data)

      open(path, 'w'){|f|
        f.print JSON.dump(data)
      }

      {:info => data[:info], :path => path}
    end

    module_function :save
  end
end
