require "test_helper"

class HocrReaderTest < Minitest::Test
  def setup
    @hocr = <<HEREDOC
  <div class='ocr_page' id='page_8818' title='image ""; bbox 0 0 341 17; ppageno 8817'>
   <div class='ocr_carea' id='block_8818_1' title="bbox 0 0 341 17">
    <p class='ocr_par' id='par_8818_1' lang='eng' title="bbox 0 0 341 17">
     <span class='ocr_line' id='line_8818_1' title="bbox 0 0 341 17; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
      <span class='ocrx_word' id='word_8818_1' lang='deu' title='bbox 0 4 49 17; x_wconf 92'>Name</span>
      <span class='ocrx_word' id='word_8818_2' title='bbox 54 4 94 17; x_wconf 90'>Arial</span>
      <span class='ocrx_word' id='word_8818_3' title='bbox 237 0 296 15; x_wconf 90'>Century</span>
      <span class='ocrx_word' id='word_8818_4' title='bbox 302 0 341 12; x_wconf 90'>Peter</span>
     </span>
    </p>
   </div>
  </div>
HEREDOC
    @reader = HocrReader::Reader.new(@hocr)
  end

  def test_that_it_has_a_version_number
    refute_nil ::HocrReader::VERSION
  end


  def test_it_extracts_words
    @reader.to_words
    assert_equal 'Name Arial Century Peter', @reader.convert_to_string.strip
  end

  def test_it_extracts_a_word
    s = "<span class='ocrx_word' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_words
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.convert_to_string.strip
    assert_equal 'xyz', r.parts[0].language
  end

  def test_it_extracts_a_line
    s = "<span class='ocr_line' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_lines
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.convert_to_string.strip
    assert_equal 'xyz', r.parts[0].language
  end

  def test_it_extracts_a_paragraph
    s = "<p class='ocr_par' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</p>"
    r = HocrReader::Reader.new(s)
    r.to_paragraphs
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.convert_to_string.strip
    assert_equal 'xyz', r.parts[0].language
  end

  def test_it_extracts_an_area
    s = "<div class='ocr_carea' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</div>"
    r = HocrReader::Reader.new(s)
    r.to_areas
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.convert_to_string.strip
    assert_equal 'xyz', r.parts[0].language
  end

  def test_it_extracts_a_page
    s = "<div class='ocr_page' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</div>"
    r = HocrReader::Reader.new(s)
    r.to_pages
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.convert_to_string.strip
    assert_equal 'xyz', r.parts[0].language
  end

end
