# frozen_string_literal: true

require 'bigdecimal'

module HocrReader
  # class Part
  class Part
    attr_accessor :part_name, :text, 
                  :x_start, :y_start, :x_end, :y_end, :language, :attributes

    def initialize(part_name, phrase, title_attributes, lang)
      @part_name = part_name[3..-2]
      @text = phrase.text
      @attributes = split_the_attributes title_attributes
      @x_start = bbox[0].to_i
      @y_start = bbox[1].to_i
      @x_end = bbox[2].to_i
      @y_end = bbox[3].to_i
      @language = lang
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
        value = []
        parameters.each do |parameter|
          value << to_numeric(parameter)
        end
      elsif numeric?(parameters[0])
        value = to_numeric(parameters[0])
      else
        value = parameters[0]
      end
      value
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

    def to_numeric(anything)
      num = BigDecimal(anything)
      if num.frac.zero?
        num.to_i
      else
        num.to_f
      end
    end

    def numeric?(str)
      Float(str) != nil rescue false
    end
  end
end
