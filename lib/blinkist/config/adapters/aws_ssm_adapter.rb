require_relative "adapter"
require "aws-sdk-ssm"

module Blinkist
  class Config
    class AwsSsmAdapter < Adapter
      def initialize(env, app_name)
        super env, app_name

        @items_cache = {}
        @client = Aws::SSM::Client.new region: "us-east-1"
      end

      def get(key, default=nil, scope: nil)
        scope ||= @app_name

        parameter = "/#{scope}/#{key}"

        unless @items_cache.key? parameter
          @items_cache[parameter] = query_ssm parameter
        end

        @items_cache[parameter]
      rescue Aws::SSM::Errors::ParameterNotFound
        default
      end

      def query_ssm(name)
        puts "querying SSM for parameter #{name}"
        @client.get_parameter({ name: name, with_decryption: true }).parameter.value
      end
    end
  end
end
