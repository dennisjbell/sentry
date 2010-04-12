# Sentry.rb
#
# Processes requests from monit (or other) 

require 'yaml'
require 'pp'

# Load rules
ROOT = "#{File.dirname(__FILE__)}"
rules = YAML.load_file(File.join(ROOT,'rules.yml'))

# Process command line
(platform, process, condition, *args) = ARGV
(process_name,process_id) =process.split(/_(?=[^_]*$)/) 

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



