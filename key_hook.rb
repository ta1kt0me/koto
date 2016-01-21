require 'mac-event-monitor'
require 'yaml'

monitor = Mac::EventMonitor::Monitor.new

key_codes = YAML.load_file 'keycode.yml'
monitor.add_listener(:key_down) do |event|
  puts event.keycode
  puts key_codes[event.keycode]
  puts '---------'
end

monitor.run
