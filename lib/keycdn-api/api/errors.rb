module KeyCDN
  class API
    module Errors
      class Error < StandardError; end

      class ErrorWithResponse < Error
        attr_reader :response

        def initialize(message, response)
          message = message << "\nbody: #{response.body.inspect}"
          super message
          @response = response
        end
      end

      class BadRequest < ErrorWithResponse; end
      class Unauthorized < ErrorWithResponse; end
      class Forbidden < ErrorWithResponse; end
      class NotFound < ErrorWithResponse; end
      class RequestFailed < ErrorWithResponse; end

      class ObjectNotFound < Error; end  
    end
  end
end
