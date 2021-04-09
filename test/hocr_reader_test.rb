# frozen_string_literal: true

require 'test_helper'

class HocrReaderTest < Minitest::Test
  def setup
    @hocr = <<HEREDOC
  <div class='ocr_page' id='page_8818' title='image ""; bbox 11 12 13 14; ppageno 8817'>
   <div class='ocr_carea' id='block_8818_1' lang='frm' title="bbox 21 22 23 24">
    <p class='ocr_par' id='par_8818_1' lang='eng' title="bbox 31 32 33 34">
      <span class='ocr_line' id='line_8818_1' title="bbox 41 42 43 44; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
        <span class='ocrx_word' id='word_8818_1' lang='deu' title='bbox 51 52 53 54; x_wconf 92'>Name</span>
        <span class='ocrx_word' id='word_8818_2' title='bbox 61 62 63 64; x_wconf 90'>Arial</span>
      </span>
    </p>
    <p class='ocr_par' id='par_8818_2' lang='eng' title="bbox 71 72 73 74">
      <span class='ocr_line' id='line_8818_1' title="bbox 81 82 83 84; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
        <span class='ocrx_word' id='word_8818_2' title='bbox 91 92 93 94; x_wconf 90'>Fantasy</span>
      </span>
    </p>
    </div>
    <div class='ocr_carea' id='block_8818_1' lang='deu' title="bbox 101 102 103 104">
      <p class='ocr_par' id='par_8818_1' lang='eng' title="bbox 111 112 113 114">
        <span class='ocr_line' id='line_8818_1' lang='fra' title="bbox 121 122 123 124; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
          <span class='ocrx_word' id='word_8818_3' title='bbox 131 132 133 134; x_wconf 90'>Century</span>
          <span class='ocrx_word' id='word_8818_4' title='bbox 141 142 143 144; x_wconf 90'>Peter</span>
       </span>
       <span class='ocr_line' id='line_8818_1' lang='fra' title="bbox 151 152 153 154; baseline -0.012 -1; x_size 16; x_descenders 4; x_ascenders 4">
          <span class='ocrx_word' id='word_8818_3' title='bbox 161 162 163 164; x_wconf 90'>Twentieth</span>
          <span class='ocrx_word' id='word_8818_4' title='bbox 171 172 173 174; x_wconf 90'>David</span>
       </span>
      </p>
   </div>
  </div>
HEREDOC
  end

  def test_that_it_has_a_version_number
    refute_nil ::HocrReader::VERSION
  end

  def test_it_extracts_words
    @reader = HocrReader::Reader.new(@hocr)
    r = @reader.to_words
    assert 4, r.length
    # assert_equal 'Name', r[0].text
    assert_equal 'word', r[0].type
    assert_equal 'Name Arial Fantasy Century Peter Twentieth David', @reader.to_s.strip
  end

  def test_it_extracts_a_word
    s = "<span class='ocrx_word' id='word_8818_4' lang='xyz' title='bbox 302 0 341 12; x_wconf 90'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_words
    assert_equal 1, r.parts.length
    assert_equal 'Peter', r.to_s.strip
    assert_equal 'xyz', r.parts[0].language
    assert_equal 'word', r.parts[0].type
  end

  def test_it_extracts_a_line
    s = "<span class='ocr_line' id='word_8818_4' lang='xyz' title='bbox 302 0 341 12; x_wconf 90'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_lines
    assert_equal 1, r.parts.length
    # assert_equal 'Peter', r.to_s.strip
    assert_equal 'xyz', r.parts[0].language
    assert_equal 'line', r.parts[0].type
  end

  def test_it_extracts_a_paragraph
    s = "<p class='ocr_par' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</p>"
    r = HocrReader::Reader.new(s)
    r.to_paragraphs
    assert_equal 1, r.parts.length
    # assert_equal 'Peter', r.to_s.strip
    assert_equal 'xyz', r.parts[0].language
    assert_equal 'paragraph', r.parts[0].type
  end

  def test_it_extracts_an_area
    s = "<div class='ocr_carea' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</div>"
    r = HocrReader::Reader.new(s)
    r.to_areas
    assert_equal 1, r.parts.length
    # assert_equal 'Peter', r.to_s.strip
    assert_equal 'xyz', r.parts[0].language
    assert_equal 'area', r.parts[0].type
  end

  def test_it_extracts_a_page
    s = "<div class='ocr_page' id='word_8818_4' lang='xyz'title='bbox 302 0 341 12; x_wconf 90'>Peter</div>"
    r = HocrReader::Reader.new(s)
    r.to_pages
    assert_equal 1, r.parts.length
    # assert_equal 'Peter', r.to_s.strip
    assert_equal 'xyz', r.parts[0].language
    assert_equal 'page', r.parts[0].type
  end

  # rubocop:disable Metrics/AbcSize
  def test_it_extracts_lines
    r = HocrReader::Reader.new(@hocr)
    lines = r.to_lines
    assert_equal 4, lines.length
    assert_equal ['Name','Arial'], lines[0].text
    refute r.parts[0].language
    assert_equal 'fra', r.parts[1].language
  end

  def test_it_extracts_areas
    r = HocrReader::Reader.new(@hocr)
    r.to_areas
    assert_equal 2, r.parts.length
    # assert_equal 'NameArialCenturyPeter', r.to_s.gsub!("\n", '').gsub!(' ', '')
    assert_equal 'frm', r.parts[0].language
    assert_equal 'deu', r.parts[1].language
  end
  # rubocop:enable Metrics/AbcSize

  def test_it_returns_a_box
    r = HocrReader::Reader.new(@hocr)
    r.to_areas
    part = r.parts[0]
    assert_equal 21, part.x_start
    assert_equal 22, part.y_start
    assert_equal 23, part.x_end
    assert_equal 24, part.y_end
  end

  def test_it_finds_string_params
    s = "<span class='ocrx_word' id='word_1_2' title='bbox 545 2012 899 2073; x_alphabet latin'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_words
    assert_equal 1, r.parts.length
    part = r.parts[0]
    assert_equal 'Peter', r.to_s.strip
    assert_equal 'latin', part.x_alphabet
  end

  def test_it_finds_confidence_levels
    s = "<span class='ocrx_word' id='word_1_2' title='bbox 545 2012 899 2073; x_wconf 95.1;'>Peter</span>"
    r = HocrReader::Reader.new(s)
    r.to_words
    assert_equal 1, r.parts.length
    part = r.parts[0]
    # pp part
    assert_equal 'Peter', part.text
    assert_equal 95.1, part.x_wconf
  end

  def test_it_creates_nested_structure
    r = HocrReader::Reader.new(@hocr)

    p = r.to_pages
    assert_equal 1, p.length
    assert_equal 11, p[0].bbox[0]
    
    assert_equal [[[['Name','Arial']],[['Fantasy']]], [[['Century', 'Peter'],['Twentieth','David']]]], p[0].text

    a = r.to_areas
    assert_equal 2,a.length
    assert_equal 21, a[0].bbox[0]
    assert_equal [[['Name','Arial']],[['Fantasy']]], a[0].text
    assert_equal [[['Century', 'Peter'],['Twentieth','David']]], a[1].text

    para = r.to_paragraphs
    assert_equal 3, para.length
    assert_equal 31, para[0].bbox[0]
    assert_equal [['Name','Arial']], para[0].text
    assert_equal [['Fantasy']], para[1].text
    assert_equal [['Century', 'Peter'],['Twentieth','David']], para[2].text

    l = r.to_lines
    assert_equal 4, l.length
    assert_equal 41, l[0].bbox[0]
    assert_equal ['Name','Arial'], l[0].text
    assert_equal ['Fantasy'], l[1].text
    assert_equal ['Century', 'Peter'], l[2].text
    assert_equal ['Twentieth','David'], l[3].text

    w = r.to_words
    assert_equal 7, w.length
    assert_equal 51, w[0].bbox[0]
    assert_equal 'Name', w[0].text
  end

  def test_lines
    r = HocrReader::Reader.new(@hocr)
    l = r.extract_parts2 :to_lines
    # pp l
    # pp l.text
  end

end
