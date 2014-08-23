module AwsReporting
  module Statistics
    def get(region, namespace, metric_name, start_time, end_time, period, dimensions, statistics)
      client = AWS::CloudWatch::Client.new(:config => Config.get, :region => region)

      datapoints = client.get_metric_statistics(:namespace => namespace,
                                                :metric_name => metric_name,
                                                :start_time => start_time.iso8601,
                                                :end_time => end_time.iso8601,
                                                :period => period,
                                                :dimensions => dimensions,
                                                :statistics => statistics)[:datapoints]

      info = {:region => region,
              :namespace => namespace,
              :metric_name => metric_name,
              :dimensions => dimensions,
              :start_time => start_time.iso8601,
              :end_time => end_time.iso8601,
              :period => period,
              :statistics => statistics,
              :unit => datapoints[0] ? datapoints[0][:unit] : nil }

      data = datapoints.sort_by{|d| d[:timestamp] }
                       .map{|d| 
                          datapoint = {}

                          datapoint[:timestamp] = d[:timestamp].iso8601
                          datapoint[:maximum] = d[:maximum] if d[:maximum]
                          datapoint[:minimum] = d[:minimum] if d[:minimum]
                          datapoint[:average] = d[:average] if d[:average]
                          datapoint[:sum] = d[:sum] if d[:sum]
                          datapoint[:sample_count] = d[:sample_count] if d[:sample_count]

                          datapoint
                       }

      {:info => info, :datapoints => data}
    end

    module_function :get
  end
end
