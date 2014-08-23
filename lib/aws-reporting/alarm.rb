module AwsReporting
  module Alarm
    def serialize(dimensions)
      dimensions.sort_by{|dimension| dimension[:name]}.map{|dimension| dimension[:name] + "=>" + dimension[:value]}.join(',')
    end

    def get_alarm_info(region, alarm)
      info = {:name => alarm.name,
              :region => region,
              :namespace => alarm.namespace,
              :dimensions => alarm.dimensions,
              :metric_name => alarm.metric_name,
              :status => get_status(alarm)}
    end

    def get_status(alarm)
      return :ALARM if alarm.state_value == 'ALARM'
      return :ALARM if alarm.history_items.to_a.select{|history| history.history_item_type == 'StateUpdate'}.length > 0
      return :OK
    end

    def get_alarms()
      alarms = []
      AWS.regions.each{|r|
        Config.update_region(r.name)
        cw = AWS::CloudWatch.new
        cw.alarms.each do |alarm|
          alarms << get_alarm_info(r.name, alarm)
        end
      }
      alarms.sort_by{|alarm| [alarm[:namespace], serialize(alarm[:dimensions]), alarm[:metric_name], alarm[:name]].join(' ')}
    end

    module_function :get_alarms
  end
end
