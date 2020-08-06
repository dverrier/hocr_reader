require "hocr_reader/version"
require "hocr_reader/part"

require 'nokogiri'

module HocrReader
  class Reader
  
    

    # Parts = ['ocr_page',
    #     'ocr_carea',
    #     'ocr_par',
    #     'ocr_line',
    #     'ocrx_word']

    #   Tags = {ocr_page: 'div class=ocr_page',
    #           ocr_carea: 'div class=ocr_carea',
    #           ocr_par: 'class=ocr_par',
    #           ocr_line: 'span class=ocr_line',
    #           ocrx_word: 'span class=ocrx_word'}

    def hocr_to_text(str)
      html = Nokogiri::HTML(str)
      extract_words_from_html(html)
    end


    def extract_words_from_html(html)
      pos_info_words = []

      html.css('span.ocrx_word, span.ocr_word')
          .reject { |word| word.text.strip.empty? }
          .each do |word|
        word_attributes = word.attributes['title'].value.to_s
                              .delete(';').split(' ')
        pos_info_word = Part.new(word, word_attributes)
        pos_info_words.push pos_info_word
      end
      pos_info_words
    end


    def to_s(pos_info_words)
      s = ''
      pos_info_words.each do |part|
        # s << part[:word] + ' '
        s << part.text + ' '
      end
      s
    end

    def word_info(word, data)
      {
        word: word.text,
        x_start: data[1].to_i,
        y_start: data[2].to_i,
        x_end: data[3].to_i,
        y_end: data[4].to_i
      }
    end

  end
end
