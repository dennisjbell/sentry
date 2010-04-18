module Sentry
  module Handler
    class Mongrel < Base

      def restart(status)
	r = status[:restart] = {}
        @log.warn("Restarting #{@request[:process_id]} due to #{@request[:condition]}")
	case @request[:platform].to_sym
	  when :monit
	    r[:result] = `sudo monit restart #{@request[:process_id]}`
	end
	r[:complete] = true
      end

    end
  end
end
