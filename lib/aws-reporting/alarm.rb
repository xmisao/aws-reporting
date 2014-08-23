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

    def alarmed?(history)
      return false unless history.history_item_type == 'StateUpdate'

      data = JSON.parse(history.history_data)
      if data["oldState"]["stateValue"] == 'INSUFFICIENT_DATA' and data["newState"]["stateValue"] == 'OK'
        false
      elsif data["oldState"]["stateValue"] == 'OK' and data["newState"]["stateValue"] == 'INSUFFICIENT_DATA'
        false
      else
        true
      end
    end

    def get_status(alarm)
      return :ALARM if alarm.state_value == 'ALARM'
      return :ALARM if alarm.history_items.to_a.select{|history| alarmed?(history)}.length > 0
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

    module_function :get_alarms, :get_alarm_info, :get_status, :serialize, :alarmed?
  end
end
