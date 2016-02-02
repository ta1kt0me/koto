require 'coreaudio'
require 'byebug'
require 'matrix'
require 'tkextlib/tcllib/plotchart'
include Tk::Tcllib::Plotchart

STANDARD_PITCH = 440.0
BIT_DEPTH = 0x05A0
PLAY_TIME = 2

tone = 3
waves = []
# (1..50).each do |i|
#   phase = STANDARD_PITCH * 2 * Math::PI / CoreAudio.default_output_device.nominal_rate
#   waves << (0...PLAY_TIME*CoreAudio.default_output_device.nominal_rate).map { |j|
#     value = 0.4 / i * Math.sin(phase * j * i) * BIT_DEPTH
#     value
#   }
# end
# data_3 = waves[0].zip(*waves[1..-1]).map { |e| e.inject(:+) }
position_in_period = 0.0
position_in_period_delta = STANDARD_PITCH / CoreAudio.default_output_device.nominal_rate
(0...PLAY_TIME*CoreAudio.default_output_device.nominal_rate).each do |i|
  # sine wave
  # waves << Math.sin(position_in_period * 2 * Math::PI) * BIT_DEPTH
  # sawtooth
  # waves << ((position_in_period * 2.0) - 1.0) * BIT_DEPTH
  # squre
  # waves << ((position_in_period >= 0.5) ? BIT_DEPTH : -BIT_DEPTH)
  # triangle
  # waves << BIT_DEPTH - (((position_in_period * 2.0) - 1.0) * BIT_DEPTH * 2.0).abs
  # white noise
  waves << rand(-BIT_DEPTH..BIT_DEPTH)
  position_in_period += position_in_period_delta
  if position_in_period >= 1.0
    position_in_period -= 1.0
  end
end

LEN = 500
# m = Matrix[*data_3]
column_zero = (0..LEN).to_a
column_one = waves[0..LEN]

TkCanvas.new(:background=>'white', :width=>1400, :height=>800){|c|
  pack(:fill=>:both)
  puts 'start create graph'
  Tk::Tcllib::Plotchart::XYPlot.new(c, [column_zero.min, column_zero.max, 1000],
                                       [column_one.min, column_one.max, 100000]){
    dataconfig('series3', color: :blue)
    waves[0..LEN].each.with_index{|y, index|
      plot('series3', index, y)
    }
    title("Data series")
  }
}
Tk.mainloop
