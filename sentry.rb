# Sentry.rb
#
# Processes requests from monit (or other) 

require 'yaml'
require 'pp'

module Sentry

  class << self
    def rules 
      reload() unless @rules
      return @rules
    end

    def reload
      @rules = YAML.load_file(File.join(File.dirname(__FILE__),'rules.yml'))
    end
  end

  class Task

    def initialize(platform, process, condition, *args)
      (process_type,process_id) =process.split(/_(?=[^_]*$)/) 
      @request = {
        :platform => platform,
	:process_type => process_type,
	:process_id => process_id,
	:condition => condition,
	:arguments => args,
	:request_time => Time.new()
      }
    end

    def process
      build_task_list(Sentry::rules['processes'])
      log "Processing request #{ARGV.collect {|a| a.inspect}.join(' ')}"
      log @task_list_description
      @task_list.each do |t|
        do_task t
      end
      log "Done."
    end

    private

    def build_task_list(rules)
      @task_list = nil
      path_index = 0
      path = [:platform,:process_type,:condition]
      path.inject(rules) do |r,p|
        @task_list = r["__default"] if r.has_key? "__default"
        rc = (r.has_key?(@request[p])) ? r[@request[p]] : nil
        break if rc.nil?
        path_index += 1
        @task_list = rc unless rc.nil? or path_index < path.length
        rc
      end

      description_elements = path.collect {|p| "#{p.to_s} '#{@request[p]}'"}
      @task_list_description = if @task_list.nil?
        @task_list = []
	"Nothing to do"
      elsif path_index == 0
        "Running default tasks -- no higher-level matching tasks found for #{description_elements.join(', ')}"
      elsif path_index < path.length
        "Running default tasks for #{description_elements[0...path_index].join(', ')} - could not find higher-level match for #{description_elements[path_index..-1].join(', ')}"
      else
        "Running tasks for #{description_elements.join(', ')}"
      end
    end

    def do_task(task)
      log "  - running '#{task.respond_to?(:has_key?) ? task.keys[0].to_s + "(options: " + task.values[0].inspect + ")" : task.to_s}"
    end

    def log(msg)
      msg.gsub!(/'/,"'\"'\"'")
      `echo '[SENTRY] #{msg}' | nc localhost 5678`
    end

  end
end

task = Sentry::Task.new(*ARGV)
task.process()

__END__


