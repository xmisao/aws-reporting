module AwsReporting
  module Plan
    def self.to_array(yaml_array)
      array = []
      yaml_array.each{|i|
        array << i.to_s
      }
      array
    end

    def self.build_template(yaml)
      template = Hash.new{|h, k| h[k] = {}}
      yaml.each{|d|
        template[d["namespace"]][d["metric_name"]] = to_array(d["statistics"])
      }
      template
    end

    DEFAULT_STATISTICS = ['Maximum', 'Minimum', 'Average']

    def self.create_plan(template, metrics)
      plan = []
      metrics.map{|m|
        namespace = m[:namespace]
        metric_name = m[:metric_name]
        dimensions = m[:dimensions]
        statiestics = nil
        if template[namespace][metric_name]
          statistics = template[namespace][metric_name]
        else
          $stderr.puts "Warning: Metric #{namespace} #{metric_name} is not defined. Default statistics are used."
          statistics = DEFAULT_STATISTICS
        end
        region = m[:region]

        {:namespace => namespace, :metric_name => metric_name, :dimensions => dimensions, :statistics => statistics, :region => region}
      }
    end

    def self.metrics_file_path()
      File.expand_path('../../../metrics/metrics.yaml', __FILE__)
    end

    def self.generate()
      yaml = YAML.load(open(metrics_file_path()){|f| f.read })
      template = build_template(yaml)

      metrics = []
      AWS.regions.each{|r|
        AwsReporting::Config.update_region(r.name)
        AWS::CloudWatch::MetricCollection.new.each{|m| metrics << {:namespace => m.namespace, :metric_name => m.metric_name, :dimensions => m.dimensions, :region => r.name}}
      }

      plan = create_plan(template, metrics)
    end
  end
end
