# frozen_string_literal: true
require 'simplecov'

SimpleCov.start do
  add_group 'unit tests', 'test/unit'
  add_group 'lib', 'lib/'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'hocr_reader'

require 'minitest/autorun'
