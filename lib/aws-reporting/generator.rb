module AwsReporting
  class Generator
    attr_accessor :path, :force

    def format_path(path)
      path.split('/')[-2..-1]
          .join('/')
    end

    def transform(metrics, name_resolvers)
      temp = Hash.new{|h, k| h[k] = Hash.new{|h, k| h[k] = [] }}
      metrics.each{|namespace, value|
        value.each{|identification, files|
          element =  {:region => identification[:region],
                      :namespace => namespace,
                      :dimensions => identification[:dimensions],
                      :files => files.sort_by{|entry| entry[:info][:metric_name]}.map{|entry| format_path(entry[:path])}}

          element[:name] = name_resolvers.get_name(element)

          dimension_type = identification[:dimensions].map{|item| item[:name]}.sort

          temp[namespace][dimension_type] << element
        }
      }

      temp2 = Hash.new{|h, k| h[k] = [] }
      temp.each{|namespace, dimension_table|
        dimension_table.each{|dimension_type, elements| 
          temp2[namespace] << {:dimension_type => dimension_type,
                               :elements => elements}
        }
      }

      result = []
      temp2.each{|namespace, dimension_table|
        result << {:namespace => namespace, :dimension_table => dimension_table}
      }

      sort_result!(result)

      result
    end

    def sort_result!(result)
      result.sort_by!{|namespace_table| namespace_table[:namespace]}
      result.each{|namespace_table|
        namespace_table[:dimension_table].sort_by!{|dimension_table| dimension_table[:dimension_type].join(' ')}
      }

      result.each{|namespace_table|
        namespace_table[:dimension_table].each{|dimension_table|
          dimension_type = dimension_table[:dimension_type]
          dimension_table[:elements].sort_by!{|element| expand(dimension_type, element[:dimensions]) }
        }
      }
    end

    def expand(dimension_type, dimensions)
      dimension_hash = {}

      dimensions.each{|dimension|
        dimension_hash[dimension[:name]] = dimension[:value]
      }

      values = []
      dimension_type.each{|dimension_name|
        values << dimension_hash[dimension_name] 
      }
      values.join(' ')
    end

    def merge_status(s0, s1)
      if s0 == nil or s1 == nil
        s0 || s1
      else
        if s0 == :ALARM or s1 == :ALARM
          'ALARM'
        else
          'OK'
        end
      end
    end

    def build_alarm_tree(alarms)
      alarm_tree = {}
      alarms.each{|alarm|
        key = {:region => alarm[:region],
               :namespace => alarm[:namespace],
               :dimensions => alarm[:dimensions],
               :metric_name => alarm[:metric_name]}
        alarm_tree[key] = merge_status(alarm_tree[key], alarm[:status])
      }
      alarm_tree
    end

    def set_status(data, alarm_tree)
      key = {:region => data[:info][:region],
             :namespace => data[:info][:namespace],
             :dimensions => data[:info][:dimensions],
             :metric_name => data[:info][:metric_name]}
      data[:info][:status] = alarm_tree[key] if alarm_tree[key]
    end

    def download(base_path, plan, start_time, end_time, period, name_resolvers, timestamp)
      metrics = Hash.new{|h, k| h[k] = Hash.new{|h, k| h[k] = []}}

      alarms = AwsReporting::Alarm.get_alarms()
      alarm_tree = build_alarm_tree(alarms)

      mutex = Mutex.new
      started_at = Time.now
      num_of_metrics = plan.length
      num_of_downloaded = 0
      Parallel.each_with_index(plan, :in_threads => 8){|entry, i|
        namespace = entry[:namespace]
        metric_name = entry[:metric_name]
        dimensions = entry[:dimensions]
        statistics = entry[:statistics]
        region = entry[:region]

        mutex.synchronize do
          num_of_downloaded += 1
          Formatador.redisplay_progressbar(num_of_downloaded, num_of_metrics, {:started_at => started_at})
        end

        data = AwsReporting::Statistics.get(region, namespace, metric_name, start_time, end_time, period, dimensions, statistics)
        set_status(data, alarm_tree)
        file = AwsReporting::Store.save(base_path, data)

        identification = {:dimensions => dimensions, :region => region}
        metrics[namespace][identification] << file
      }

      report_info = {:start_time => start_time.to_s,
                     :end_time => end_time.to_s,
                     :period => period.to_s,
                     :timestamp => timestamp.to_s,
                     :num_of_metrics => plan.length.to_s,
                     :version => Version.get}

      open(base_path + '/metrics.json', 'w'){|f|
        f.print JSON.dump({:report_info => report_info, :metrics => transform(metrics, name_resolvers), :alarms => alarms})
      }
    end

    def copy_template(path, force)
      report_path = File.expand_path(path)
      if force != true and File.exist?(path)
        error = AwsReporting::Error::OverwriteError.new
        error.path = report_path
        raise error
      end

      template_path = File.expand_path('../../../template', __FILE__)
      template_files = Dir.glob(template_path + '/*')
      FileUtils.mkdir_p(report_path)
      FileUtils.cp_r(template_files, report_path)
    end

    def generate
      timestamp = Time.now

      AwsReporting::Config.load()

      puts 'Report generating started.'
      copy_template(@path, @force)
      data_dir = @path + '/data'

      puts '(1/3) Planning...'
      plan = Plan.generate
      puts "Planning complete."
      start_time = Time.now - 24 * 60 * 60 * 14
      end_time = Time.now
      period = 60 * 60
      puts '(2/3) Building name tables...'
      name_resolvers = AwsReporting::Resolvers.new
      name_resolvers.init
      puts 'Name tables were builded.'
      puts '(3/3) Downloading metrics...'
      download(data_dir, plan, start_time, end_time, period, name_resolvers, timestamp)
      puts 'Downloading metrics done.'
      puts 'Report generating complete!'
    end
  end
end
