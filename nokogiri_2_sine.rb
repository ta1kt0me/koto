require 'coreaudio'
require 'byebug'

dev = CoreAudio.default_output_device
buf = dev.output_buffer(1024)
PLAY_TIME = 2

th = Thread.start do
  STANDARD_PITCH = 440
  BIT_DEPTH = 0x35A0

  def frequence(tone)
    2**(tone / 12.0)
  end

  def build_wave(type)
    waves = []
    position_in_period = 0.0
    position_in_period_delta = STANDARD_PITCH / CoreAudio.default_output_device.nominal_rate
    # phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (0/12.0) / CoreAudio.default_output_device.nominal_rate
    (0..PLAY_TIME*CoreAudio.default_output_device.nominal_rate).each do |i|
      case type
      when 'sine' then
        # waves << Math.sin(phase*i) * BIT_DEPTH
        waves << Math.sin(position_in_period * Math::PI * frequence(0)) * BIT_DEPTH
      when 'sawtooth' then
        # sawtooth
        waves << ((position_in_period * 2.0) - 1.0) * BIT_DEPTH
      when 'square' then
        # square
        waves << ((position_in_period >= 0.5) ? BIT_DEPTH : -BIT_DEPTH)
      when 'triangle' then
        # triangle
        waves << BIT_DEPTH - (((position_in_period * 2.0) - 1.0) * BIT_DEPTH * 2.0).abs
      when 'noise' then
        # white noise
        waves << rand(-BIT_DEPTH..BIT_DEPTH)
      end
      position_in_period += position_in_period_delta

      position_in_period -= 1.0 if position_in_period >= 1.0
    end
    waves
  end

  def build_synthesis_wave
    waves = []
    waves_0 = []

    position_in_period = 0.0
    position_in_period_delta = STANDARD_PITCH / CoreAudio.default_output_device.nominal_rate

    (0...PLAY_TIME * CoreAudio.default_output_device.nominal_rate).each do |_|
      waves << Math.sin(position_in_period * frequence(0) * 2 * Math::PI) * BIT_DEPTH
      waves_0 << rand(-BIT_DEPTH..BIT_DEPTH)
      position_in_period += position_in_period_delta

      position_in_period -= 1.0 if position_in_period >= 1.0
    end

    waves.zip(waves_0).map { |e| e.inject(:+) }
  end

  if ARGV[0] == 'single'
    buf << build_wave(ARGV[1])
  else
    buf << build_synthesis_wave
  end
end

buf.start
sleep PLAY_TIME * 5
buf.stop

puts "#{buf.dropped_frame} frame dropped."

th.kill.join
