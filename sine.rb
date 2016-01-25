require "coreaudio"

dev = CoreAudio.default_output_device
buf = dev.output_buffer(1024)
STANDARD_PITCH = 440
# BIT_DEPTH = 0x7FFF
BIT_DEPTH = 0x05A0
PLAY_TIME = 2

phase = Math::PI * 2.0 * STANDARD_PITCH / dev.nominal_rate
th = Thread.start do
  wave = (0...PLAY_TIME * dev.nominal_rate).map do |i|
    Math.sin(phase*i)
  end
  wave = wave.map { |v| v * BIT_DEPTH }
  buf << wave
  # see sine wave
  wave.each do |w|
    puts '#' * (w/10).round.abs
  end
end

buf.start
sleep PLAY_TIME
buf.stop

puts "#{buf.dropped_frame} frame dropped."

th.kill.join
