# frozen_string_literal: true

module HocrReader
  TAGS = { to_pages: '.ocr_page',
           to_areas: '.ocr_carea',
           to_paragraphs: '.ocr_par',
           to_lines: '.ocr_line',
           to_words: '.ocrx_word' }.freeze
  CHILDREN = { to_pages: :to_areas,
               to_areas: :to_paragraphs,
               to_paragraphs: :to_lines,
               to_lines: :to_words }.freeze
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

    def extract_parts(part_name)
      @parts = []
      tag = TAGS[part_name]
      tag_pair = tag + ', ' + tag
      @html.css(tag_pair)
           .reject { |node| node.text.strip.empty? }.each do |node|
        @parts.push create_part_from_node(part_name, node)
      end
      @parts
    end

    def create_part_from_node(part_name, node, parent = nil)
      child_name = CHILDREN[part_name]
      child_tag = TAGS[child_name]

      new_part = create_part part_name, node, parent
      if child_tag
        child_pair = child_tag + ', ' + child_tag
        node.children.css(child_pair).each do |child_node|
          new_part.children << create_part_from_node(child_name, child_node, new_part)
        end
      end
      new_part
    end

    def create_part(part_name, part, parent)
      title_attributes = part.attributes['title'].value.to_s.split(';')
      if part.attributes['lang']
        language_attribute = part.attributes['lang'].value.to_s
      elsif parent
        language_attribute = parent.language
      end
      Part.new(part_name, part, title_attributes, language_attribute, parent)
    end

    def to_s
      s = ''
      @parts.each { |part| s += (part.text + ' ') if part.text }
      s
    end

    def to_a
      a = []
      @parts.each { |part| a << part.text }
    end
  end
end
