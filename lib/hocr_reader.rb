require "hocr_reader/version"
require "hocr_reader/part"

require 'nokogiri'

module HocrReader
  Parts = [:ocr_page,
        :ocr_carea,
        :ocr_par,
        :ocr_line,
        :ocrx_word]

  Tags = {ocr_page: 'div class=ocr_page',
          ocr_carea: 'div class=ocr_carea',
          ocr_par: 'class=ocr_par',
          ocr_line: 'span class=ocr_line',
          ocrx_word: 'span.ocrx_word'}

  class Reader
    attr_accessor :string, :parts
    def initialize(str)
      @string = str
    end

    def hocr_to_text
      html = Nokogiri::HTML(@string)
      extract_parts_from_html(html,:ocrx_word)
      convert_to_s(@parts)
    end


    def extract_parts_from_html(html, part_name)
      @parts = []
      tag = Tags[part_name]
      tag_pair = tag + ', ' + tag
      # 'span.ocrx_word, span.ocr_word'
        html.css(tag_pair)
          .reject { |word| word.text.strip.empty? }
          .each do |word|
        word_attributes = word.attributes['title'].value.to_s
                              .delete(';').split(' ')
        part = Part.new(word, word_attributes)
        @parts.push part
      end
    end


    def convert_to_s(parts)
      s = ''
      parts.each {|part| s = s + part.text + ' '}
      s
    end

  end
end
