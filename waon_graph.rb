require "coreaudio"
require 'matrix'
require 'tkextlib/tcllib/plotchart'
include Tk::Tcllib::Plotchart

dev = CoreAudio.default_output_device
buf = dev.output_buffer(1024)
STANDARD_PITCH = 440
BIT_DEPTH = 0x25A0
PLAY_TIME = 12

wave_a = [0].map { |i|
  phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / dev.nominal_rate
  (0...dev.nominal_rate).map { |j|
    Math.sin(phase*j) * BIT_DEPTH
  }
}.flatten
wave_e = [7].map { |i|
  phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / dev.nominal_rate
  (0...dev.nominal_rate).map { |j|
    Math.sin(phase*j) * BIT_DEPTH
  }
}.flatten
wave_c = [3].map { |i|
  phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / dev.nominal_rate
  (0...dev.nominal_rate).map { |j|
    Math.sin(phase*j) * BIT_DEPTH
  }
}.flatten
wave = wave_a.zip(wave_e, wave_c).map { |arr| arr.inject :+ }
data = (0...dev.nominal_rate).map { |j|
  [j, wave[j]]
}

LEN = 1500
m = Matrix[*data]
column_zero = m.column(0).to_a[0..LEN]
column_one  = m.column(1).to_a[0..LEN]

TkCanvas.new(:background=>'white', :width=>1400, :height=>800){|c|
  pack(:fill=>:both)
  puts 'start create graph'
  Tk::Tcllib::Plotchart::XYPlot.new(c, [column_zero.min, column_zero.max, 100],
                                       [column_one.min, column_one.max, 100]){
    dataconfig('series3', color: :blue)
    data[0..LEN].each{|x, y|
      plot('series3', x, y)
    }
    title("Data series")
  }
}
Tk.mainloop
