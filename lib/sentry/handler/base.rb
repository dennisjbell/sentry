module Sentry
  module Handler
    class Base

      def initialize(request,logObj)
        @request = request
	@log = logObj
      end

    end
  end
end

