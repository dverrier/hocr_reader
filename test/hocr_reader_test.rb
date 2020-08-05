require "test_helper"

class HocrReaderTest < Minitest::Test
  def setup
    @hocr = <<HEREDOC
  <div class='ocr_page' id='page_8818' title='image ""; bbox 0 0 341 17; ppageno 8817'>
   <div class='ocr_carea' id='block_8818_1' title="bbox 0 0 341 17">
    <p class='ocr_par' id='par_8818_1' lang='eng' title="bbox 0 0 341 17">
     <span class='ocr_line' id='line_8818_1' title="bbox 0 0 341 17; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
      <span class='ocrx_word' id='word_8818_1' title='bbox 0 4 49 17; x_wconf 92'>Name</span>
      <span class='ocrx_word' id='word_8818_2' title='bbox 54 4 94 17; x_wconf 90'>Arial</span>
      <span class='ocrx_word' id='word_8818_3' title='bbox 237 0 296 15; x_wconf 90'>Century</span>
      <span class='ocrx_word' id='word_8818_4' title='bbox 302 0 341 12; x_wconf 90'>Peter</span>
     </span>
    </p>
   </div>
  </div>
HEREDOC
    @reader = HocrReader::Reader.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::HocrReader::VERSION
  end

  def test_it_extracts_words
    assert_equal 'Name Arial Century Peter',extract_words_from_html(@hocr).strip   
  end
end
