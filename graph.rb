require 'coreaudio'
require 'matrix'
require 'tkextlib/tcllib/plotchart'
include Tk::Tcllib::Plotchart

STANDARD_PITCH = 400
BIT_DEPTH = 0x05A0
PLAY_TIME = 12

data_3 = []
# [3, 5, 7, 8, 10, 12, 14, 15].map { |i|
[3].map { |i|
  phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / CoreAudio.default_output_device.nominal_rate
  (0...CoreAudio.default_output_device.nominal_rate).map { |j|
    value = Math.sin(phase*j) * BIT_DEPTH
    data_3 << [j * i, value]
  }
}

data_1 = []
[1].map { |i|
  phase = Math::PI * 2.0 * STANDARD_PITCH * 2 ** (i/12.0) / CoreAudio.default_output_device.nominal_rate
  (0...CoreAudio.default_output_device.nominal_rate).map { |j|
    value = Math.sin(phase*j) * BIT_DEPTH
    data_1 << [j * i, value]
  }
}

LEN = 500
m = Matrix[*data_3]
column_zero = m.column(0).to_a[0..LEN]
column_one  = m.column(1).to_a[0..LEN]

m = Matrix[*data_1]
column_1_zero = m.column(0).to_a[0..LEN]
column_1_one  = m.column(1).to_a[0..LEN]
TkCanvas.new(:background=>'white', :width=>1400, :height=>800){|c|
  pack(:fill=>:both)
  puts 'start create graph'
  Tk::Tcllib::Plotchart::XYPlot.new(c, [column_zero.min, column_zero.max, 100],
                                       [column_one.min, column_one.max, 1000]){
    dataconfig('series1', color: :red)
    dataconfig('series3', color: :blue)
    data_3[0..LEN].each{|x, y|
      plot('series3', x, y)
    }
    data_1[0..LEN*3].each{|x, y|
      plot('series1', x, y)
    }
    title("Data series")
  }
}
Tk.mainloop
