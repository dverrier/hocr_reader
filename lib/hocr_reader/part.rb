# frozen_string_literal: true

require 'bigdecimal'

module HocrReader
  # class Part
  class Part
    attr_accessor :type, :children, :part_id, :parent, 
                  :language, :attributes

    def initialize(part_name, phrase, title_attributes, lang,  part_id, parent)
      @type = part_name[3..-2]
      @text = phrase.text if @type == 'word'
      @children = []
      @attributes = split_the_attributes title_attributes
      @language = lang
      @part_id = part_id
      @parent = parent
    end

    def first_child
      @children[0]
    end

    def last_child
      @children[-1]
    end

    def x_start
      bbox[0].to_i
    end

    def y_start
      bbox[1].to_i
    end

    def x_end
      bbox[2].to_i
    end

    def y_end
      bbox[3].to_i
    end

    def width
      x_end - x_start
    end
    
    def height
      y_end - y_start
    end

    def text
      if @children.empty?
        @text
      else
        children.inject([]) { |text_array, c| text_array << c.text }
      end
    end

    def split_the_attributes(title_attributes)
      attributes = {}
      individual_attributes = []
      title_attributes.each { |attrs| individual_attributes << attrs.split(' ') }
      # store the attibutes as keys in a hash that point to the value(s)
      individual_attributes.each do |attribute|
        key = attribute[0].to_sym
        attributes[key] = convert_to_parameters attribute
      end
      attributes
    end

    def convert_to_parameters(attribute)
      parameters = attribute.slice(1..-1)
      if parameters.length > 1
        to_list(parameters)
      elsif numeric?(parameters[0])
        to_numeric(parameters[0])
      else
        parameters[0]
      end
    end

    def method_missing(name, *args, &block)
      @attributes[name] || super
    end

    def respond_to_missing?(name, *)
      if @attributes[name]
      else
        super
      end
    end

    def to_list(parameters)
      value = []
      parameters.each do |parameter|
        value << to_numeric(parameter)
      end
      value
    end

    def to_numeric(anything)
      num = BigDecimal(anything)
      if num.frac.zero?
        num.to_i
      else
        num.to_f
      end
    end

    def numeric?(str)
      !Float(str).nil?
    rescue StandardError
      false
    end

    def to_s
      text
    end
  end
end
