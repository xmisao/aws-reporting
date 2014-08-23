module AwsReporting
  module Resolver
    class EC2Resolver
      def initialize
        @ec2_name_table = {}
      end

      def self.namespace
        "AWS/EC2"
      end

      def self.dimension_type
        ["InstanceId"].sort
      end

      def init
        AWS.regions.each{|r|
          Config.update_region(r.name)
          ec2 = AWS::EC2.new
          ec2.instances.each{|instance|
            @ec2_name_table[instance.id] = instance.tags["Name"]
          }
        }
      end

      def get_name(element)
        id = get_value(element[:dimensions], "InstanceId")
        @ec2_name_table[id]
      end
    end
  end
end
