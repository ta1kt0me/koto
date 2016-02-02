require 'coreaudio'
require 'byebug'

dev = CoreAudio.default_output_device
buf = dev.output_buffer(1024)
STANDARD_PITCH = 440
BIT_DEPTH = 0x15A0
PLAY_TIME = 2

th = Thread.start do
  waves = []
  position_in_period = 0.0
  position_in_period_delta = STANDARD_PITCH / CoreAudio.default_output_device.nominal_rate
  (0...PLAY_TIME*CoreAudio.default_output_device.nominal_rate).each do |i|
    # sine wave
    # waves << Math.sin(position_in_period * 2 * Math::PI) * BIT_DEPTH
    # sawtooth
    # waves << ((position_in_period * 2.0) - 1.0) * BIT_DEPTH
    # square
    # waves << ((position_in_period >= 0.5) ? BIT_DEPTH : -BIT_DEPTH)
    # triangle
    # waves << BIT_DEPTH - (((position_in_period * 2.0) - 1.0) * BIT_DEPTH * 2.0).abs
    # white noise
    # waves << rand(-BIT_DEPTH..BIT_DEPTH)
    position_in_period += position_in_period_delta
    if position_in_period >= 1.0
      position_in_period -= 1.0
    end
  end
  buf << waves
  # see sine wave
  waves.each do |w|
    puts '#' * (w/100).round.abs
  end
end

buf.start
sleep PLAY_TIME
buf.stop

puts "#{buf.dropped_frame} frame dropped."

th.kill.join
