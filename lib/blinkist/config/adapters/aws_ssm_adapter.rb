require_relative "adapter"
require "aws-sdk-ssm"

module Blinkist
  class Config
    class AwsSsmAdapter < Adapter
      class << self
        attr_accessor :aws_region
      end

      DEFAULT_PREFIX = "/application/".freeze

      def initialize(env, app_name)
        if self.class.aws_region.nil?
          raise "Please set #{self.class}.aws_region = 'eu-west-1' (example) during initialization" 
        end
        
        super env, app_name

        @items_cache = {}
        @client = Aws::SSM::Client.new region: self.class.aws_region
      end

      def get(key, default=nil, scope: nil)
        prefix = prefix_for(scope)

        query_ssm_parameter "#{prefix}/#{key}"
      rescue Aws::SSM::Errors::ParameterNotFound
        default
      end

      def preload(scope: nil)
        query_all_ssm_parameters prefix_for(scope)
      end

      private

      def prefix_for(scope)
        if scope.nil?
          DEFAULT_PREFIX + @app_name
        else
          DEFAULT_PREFIX + scope
        end
      end

      def query_ssm_parameter(name)
        @items_cache[name] ||= begin
          @items_cache[name] = @client.get_parameter({ name: name, with_decryption: true }).parameter.value
        end
      end

      def query_all_ssm_parameters(prefix)
        @client.get_parameters_by_path(path: prefix, recursive: true, with_decryption: true).parameters.map do |parameter|
          @items_cache[parameter.name] = parameter.value
        end
      end
    end
  end
end
