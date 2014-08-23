module AwsReporting
  module Resolver
    class EBSResolver
      def initialize
        @ebs_name_table = {}
      end

      def self.namespace
        "AWS/EBS"
      end

      def self.dimension_type
        ["VolumeId"].sort
      end

      def init
        AWS.regions.each{|r|
          Config.update_region(r.name)
          ec2 = AWS::EC2.new
          ec2.volumes.each{|volume|
            @ebs_name_table[volume.id] = volume.tags["Name"]
          }
        }
      end

      def get_name(element)
        id = get_value(element[:dimensions], "VolumeId")
        @ebs_name_table[id]
      end
    end
  end
end
