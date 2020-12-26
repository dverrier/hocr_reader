# frozen_string_literal: true

module HocrReader
  TAGS = { to_pages: '.ocr_page',
           to_areas: '.ocr_carea',
           to_paragraphs: '.ocr_par',
           to_lines: '.ocr_line',
           to_words: '.ocrx_word' }.freeze
  # class reader
  class Reader
    attr_accessor :parts

    def initialize(str)
      @string = str
      @html = Nokogiri::HTML(@string)
    end

    def method_missing(name, *args, &block)
      if TAGS[name]
        extract_parts name
      else
        super
      end
    end

    def respond_to_missing?(name, *)
      if TAGS[name]
      else
        super
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def extract_parts(part_name)
      @parts = []
      tag = TAGS[part_name]
      tag_pair = tag + ', ' + tag
      # example tags 'span.ocrx_word, span.ocrx_word'
      @html.css(tag_pair)
           .reject { |part| part.text.strip.empty? }
           .each do |part|
        title_attributes = part.attributes['title'].value.to_s
                               .split(';')
        language_attribute = part.attributes['lang'].value.to_s if part.attributes['lang']
        this_part = Part.new(part_name, part, title_attributes, language_attribute)
        @parts.push this_part
      end
      @parts
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def convert_to_string
      s = ''
      @parts.each { |part| s += part.text + ' ' }
      s
    end
  end
end
