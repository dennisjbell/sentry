require 'rubygems'
require 'json'

module Sentry
  module Handler
    class Base

      def initialize(request,logObj)
        @request = request
	@log = logObj
      end

      def snapshot(status,*args)
        r = status[:snapshot] = {}
	r[:results] = {
	  :disk => `df -hT`,
	  :freemem  => `free -m`,
	  :mem => `cat /proc/meminfo`,
	  :io   => `iostat`,
	  :proc => `ps auwwx`,
	  :loadavg => `cat /proc/loadavg`,
	  :vmstat => `vmstat`
	}
	@log.info("Snapshot Output")
	@log.info(r[:results].to_json)
	r[:complete] = true
      end

      def notify_support(status,*args)
        r = status[:notify_support] = {}
      end

    end
  end
end

