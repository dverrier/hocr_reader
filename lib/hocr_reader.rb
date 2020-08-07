require "hocr_reader/version"
require "hocr_reader/part"

require 'nokogiri'

module HocrReader

  Tags = {pages: '.ocr_page',
          areas: '.ocr_carea',
          paragraphs:   '.ocr_par',
          lines:  '.ocr_line',
          words: '.ocrx_word'}

  class Reader
    attr_accessor :parts

    def initialize(str)
      @string = str
      @html = Nokogiri::HTML(@string)
    end

    def method_missing(name, *args, &block)
      if name == :to_pages
        extract_parts :pages
      elsif name == :to_areas
        extract_parts :areas
      elsif name == :to_paragraphs
        extract_parts :paragraphs
      elsif name == :to_lines
        extract_parts :lines
      elsif name == :to_words
        extract_parts :words
      else
        super
      end
    end


    def extract_parts( part_name)
      @parts = []
      tag = Tags[part_name]
      tag_pair = tag + ', ' + tag
      # example tags 'span.ocrx_word, span.ocrx_word'
        @html.css(tag_pair)
          .reject { |part| part.text.strip.empty? }
          .each do |part|
        title_attributes = part.attributes['title'].value.to_s
                              .delete(';').split(' ')
        if part.attributes['lang']
          language_attribute = part.attributes['lang'].value.to_s
        end
        this_part = Part.new(part, title_attributes, language_attribute)
        @parts.push this_part
      end
    end


    def convert_to_string
      s = ''
      @parts.each {|part| s += part.text + ' '}
      s
    end

  end
end
