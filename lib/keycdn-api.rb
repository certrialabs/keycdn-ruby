require "excon"
require "multi_json"
require "base64"
require 'uri'

require "keycdn-api/api/errors"
require "keycdn-api/api/zones"

module KeyCDN
  class API
    ENDPOINT = 'https://api.keycdn.com'

    def initialize(options = {})
      api_key = "#{options.delete(:api_key)}:"

      options[:headers] = options[:headers].nil? ? {} : options[:headers]
      options[:headers] = ({
        'Authorization' => "Basic #{Base64.encode64(api_key).gsub("\n", '')}",
      }).merge(options[:headers])

      @connection = Excon.new(ENDPOINT, options)
    end

    def request(params, &block)
      if [:post, :put].include?(params[:method])
        params[:body] = URI.encode_www_form(params[:body])

        params[:headers] = params[:headers].nil? ? {} : params[:headers]
        params[:headers] = { "Content-Type" => "application/x-www-form-urlencoded" }
      end

      begin
        response = @connection.request(params, &block)
      rescue Excon::Errors::HTTPStatusError => error
        klass = case error.response.status
          when 400 then KeyCDN::API::Errors::BadRequest
          when 401 then KeyCDN::API::Errors::Unauthorized
          when 403 then KeyCDN::API::Errors::Forbidden
          when 404 then KeyCDN::API::Errors::NotFound
          when /50./ then KeyCDN::API::Errors::RequestFailed
          else KeyCDN::API::Errors::ErrorWithResponse
        end

        reerror = klass.new(error.message, error.response)
        reerror.set_backtrace(error.backtrace)
        raise(reerror)
      end

      if response.body && !response.body.empty?
        res = MultiJson.load(response.body)
      else
        raise KeyCDN::API::Errors::ErrorWithResponse.new('Empty response body', response)
      end

      raise KeyCDN::API::Errors::ErrorWithResponse.new(res['description'], response) unless res['status'] == 'success'

      @connection.reset

      if !res['data'].nil? && !res['data'].empty? && res['data'].keys.size == 1
        res['data'][res['data'].keys.first]
      elsif !res['data'].nil?
        res['data']
      else
        res
      end
    end

    [:get, :post, :delete, :put].each do |method_name|
      define_method method_name do |path, query = {}|
        params = {
          :expects  => 200,
          :method   => method_name,
          :path     => "#{path}.json",
        }

        if method_name == :get && !query.empty?
          params[:query] = query
        elsif !query.empty?
          params[:body] = query
        end
        request(params)
      end
    end
  end
end
