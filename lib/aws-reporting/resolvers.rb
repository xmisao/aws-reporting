module AwsReporting
  class Resolvers
    def initialize
      @resolvers = Hash.new{|h, k| h[k] = {}}
    end

    def init
      resolvers = [AwsReporting::Resolver::EC2Resolver,
                   AwsReporting::Resolver::EBSResolver]
      
      resolvers.each{|resolver_class|
        resolver = resolver_class.new
        resolver.init
        @resolvers[resolver_class.namespace][resolver_class.dimension_type] = resolver
      }
    end

    def get_name(element)
      namespace = element[:namespace]
      dimension_type = element[:dimensions].map{|d| d[:name]}.sort

      resolver = @resolvers[namespace][dimension_type]

      return nil unless resolver

      resolver.get_name(element)
    end
  end
end
