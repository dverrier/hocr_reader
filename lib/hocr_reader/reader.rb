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

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def create_part(part_name, part)
       title_attributes = part.attributes['title'].value.to_s.split(';')
        language_attribute = part.attributes['lang'].value.to_s if part.attributes['lang']
        Part.new(part_name, part, title_attributes, language_attribute)
    end

    def extract_parts(part_name)
      @parts = []
      tag = TAGS[part_name]
      tag_pair = tag + ', ' + tag
      @html.css(tag_pair)
        .reject { |node| node.text.strip.empty? }.each do |node|
        @parts.push process_node(part_name, node)
      end
      @parts
    end

    def process_node(part_name, node, parent = nil)
      tag = TAGS[part_name]
      child_name = CHILDREN[part_name]
      child_tag = TAGS[child_name]
      tag_pair = tag + ', ' + tag
      if child_tag
        child_pair = child_tag + ', ' + child_tag
      end
      parent = create_part part_name, node
      if child_tag
        node.children.css(child_pair).each do |child_node|
          parent.children << (process_node(child_name, child_node, parent)) if parent
        end
      end
      parent
    end

    def to_s
      s = ''
      @parts.each { |part| s += (part.text + ' ') if part.text }
      s
    end

    def to_a
      a =[]
      @parts.each {|part| a << part.text}
    end
  end
end
