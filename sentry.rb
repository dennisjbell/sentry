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
      `echo 'eystuff #{@request.pretty_inspect} ' | nc localhost 5678`
    end

    private

    def build_task_list
      
    end

    def dotask
    end

  end
end

task = Sentry::Task.new(*ARGV)
task.process()

__END__
# Find what to do
to_do_options = [
  rules['processes'].fetch(platform,{}).fetch(process_name,{}).fetch(condition,nil),
  rules['processes'].fetch(platform,{}).fetch(process_name,{}).fetch('__default',nil),
  rules['processes'].fetch(platform,{}).fetch('__default',nil)
]

puts "Processing request #{ARGV.inspect}:"
unless to_do_options[0].nil?
  puts "  Processing actions for #{condition} condition:"
  print "   - running '#{to_do_options[0].collect {|x| x.respond_to?(:has_key?) ? x.keys[0].to_s + "(options: " + x.values[0].inspect + ")" : x.to_s}.join("'\n   - running '")}'\n"
  puts "Done.\n"
  exit
end

unless to_do_options[1].nil?
  puts "  Could not find handler for #{condition} condition, running default #{process_name} handler:"
  print "   - running '#{to_do_options[1].collect {|x| x.respond_to?(:has_key?) ? x.keys[0].to_s + "(options: " + x.values[0].inspect + ")" : x.to_s}.join("'\n   - running '")}'\n"
  puts "Done.\n"
  exit
end

unless to_do_options[2].nil?
  puts "  Could not find handler for #{condition} or default conditions for #{process_name}, running default handler for #{platform}:"
  print "   - running '#{to_do_options[2].collect {|x| x.respond_to?(:has_key?) ? x.keys[0].to_s + "(options: " + x.values[0].inspect + ")" : x.to_s}.join("'\n   - running '")}'\n"
  puts "Done.\n"
  exit
end

if to_do_options == [nil,nil,nil]
  puts "Nothing to do\n"
  exit
end



