require 'rubygems'
require 'json'

module Sentry
  module Handler
    class Generic < Base

      def snapshot(status)
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

      def notify_support(status)
        r = status[:notify_support] = {}
	if File.exist? '/etc/chef/dna.json'
	  host = `curl http://169.254.169.254/latest/meta-data/instance-id`
	else
	  host = `hostname -f`
	end
	`echo 'eyhelp #{@request[:condition]} has happened on #{host}' | tee /tmp/out | nc localhost 5678`
	# send current content of r to gist
	# alert desired channel about condition and gist url
      end

    end
  end
end

