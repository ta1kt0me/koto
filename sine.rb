require "coreaudio"

dev = CoreAudio.default_output_device
buf = dev.output_buffer(1024)
STANDARD_PITCH = 400
BIT_DEPTH = 0x25A0
PLAY_TIME = 12

th = Thread.start do
  wave = [3, 5, 7, 8, 10, 12, 14, 15].map { |i|
    phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / dev.nominal_rate
    (0...dev.nominal_rate).map { |j|
      Math.sin(phase*j) * BIT_DEPTH
    }
  }.flatten

  buf << wave
  # see sine wave
  wave.each do |w|
    puts '#' * (w/100).round.abs
  end
end

buf.start
sleep PLAY_TIME
buf.stop

puts "#{buf.dropped_frame} frame dropped."

th.kill.join
