require "hocr_reader/version"

module HocrReader
  class Part
    attr_accessor :text, :x_start, :y_start,:x_end, :y_end, :language

    def initialize(word, data, lang)
      @text = word.text
      @x_start = data[1].to_i
      @y_start = data[2].to_i
      @x_end = data[3].to_i
      @y_end = data[4].to_i
      @language = lang
    end  

  end
end
