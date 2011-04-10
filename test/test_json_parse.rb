$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'test/unit'

require 'reactionary/json_parse'

class TestJsonParse < Test::Unit::TestCase

  def test_parse_unicode
    text = 'last week the DM ran a story on the chap who sells the clothes donated to the salvation army making \u00A311m and the Sally Army making \u00A316M from it, hardly a two bob industry.'
    result = JsonParse.json_parse(text)
    assert_equal(
      'last week the DM ran a story on the chap who sells the clothes donated to the salvation army making £11m and the Sally Army making £16M from it, hardly a two bob industry.',
      result)
  end
  
  def test_parse_apostrophe
    text = "One reason why I always bag stuff up for the charity shop and take it in personally. At least you know it\\'s got to the shop."
    result = JsonParse.json_parse(text)
    assert_equal(
      "One reason why I always bag stuff up for the charity shop and take it in personally. At least you know it's got to the shop.",
      result)
  end
  
  def test_parse_quotes
    text = 'their health and safety \\"rulebook\\"'
    result = JsonParse.json_parse(text)
    assert_equal(
      'their health and safety "rulebook"',
      result)
  end

  def test_parse_slash
    text = '2 \\/ 2 is 2'
    result = JsonParse.json_parse(text)
    assert_equal(
      '2 / 2 is 2',
      result)
  end
  
  def test_parse_slash_b
    text = 'I blame the \\bparents'
    result = JsonParse.json_parse(text)
    assert_equal(
      'I blame the parents',
      result)
  end
    
  def test_parse_slash_f
    text = 'I blame \\fthe young generation'
    result = JsonParse.json_parse(text)
    assert_equal(
      'I blame the young generation',
      result)
  end
  
  def test_parse_newline
    text = "Geoff, Wigan .uk, 14/2/2011 08:46\\n\\n\\nMy thoughts exactly Geoff."
    result = JsonParse.json_parse(text)
    assert_equal(
      "Geoff, Wigan .uk, 14/2/2011 08:46


My thoughts exactly Geoff.",
      result)
  end
  
    def test_parse_carriage_return
      text = "Geoff, Wigan .uk, 14/2/2011 08:46\\r\\r\\rMy thoughts exactly Geoff."
      result = JsonParse.json_parse(text)
      assert_equal(
        "Geoff, Wigan .uk, 14/2/2011 08:46   My thoughts exactly Geoff.",
        result)
    end

    def test_parse_tab
      text = "Hanging is too good for them\\t\\tBroken Britain"
      result = JsonParse.json_parse(text)
      assert_equal(
        "Hanging is too good for them  Broken Britain",
        result)
    end

end
