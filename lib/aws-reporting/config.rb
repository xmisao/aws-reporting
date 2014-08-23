module AwsReporting
  class Config
    def self.config_file_path()
      File.expand_path('~/.aws-reporting/config.yaml')
    end

    def self.load()
      @@config = YAML.load(open(config_file_path()){|f| f.read})
    rescue
      raise AwsReporting::ConfigFileLoadError.new
    end

    def self.update_region(region)
      AWS.config(:access_key_id => @@config[:access_key_id],
                 :secret_access_key => @@config[:secret_access_key],
                 :region => region)
    end

    def self.get()
      AWS.config(:access_key_id => @@config[:access_key_id],
                 :secret_access_key => @@config[:secret_access_key])
    end
  end
end
