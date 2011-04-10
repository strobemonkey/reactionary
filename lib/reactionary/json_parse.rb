class JsonParse
  
  def self.json_parse(text)
    text = remove_unicode(text)
    text = remove_apostrophe(text)
    text = remove_quotes(text)
    text = remove_slash(text)
    text = remove_slash_b(text)
    text = remove_slash_f(text)
    text = remove_newline(text)
    text = remove_carriage_return(text)
    text = remove_tab(text)
    text
  end

  private
  
  def self.remove_unicode(text)
    text.gsub(/\\u([0-9A-Fa-f]{4})/) { |match| [Integer($1.hex)].pack("U*") }
  end

  def self.remove_apostrophe(text)
    text.gsub(/(\\')/) { |match| "'" }
  end
  
  def self.remove_quotes(text)
    text.gsub(/(\\")/) { |match| '"' }
  end

  def self.remove_slash(text)
    text.gsub(/(\\\/)/) { |match| "\/" }
  end

  def self.remove_slash_b(text)
    text.gsub(/(\\b)/) { |match| "" }
  end

  def self.remove_slash_f(text)
    text.gsub(/(\\f)/) { |match| "" }
  end

  def self.remove_newline(text)
    text.gsub(/(\\n)/) { |match| "\n" }
  end

  def self.remove_carriage_return(text)
    text.gsub(/(\\r)/) { |match| " " }
  end

  def self.remove_tab(text)
    text.gsub(/(\\t)/) { |match| " " }
  end

  # '"':  '"',
  # '\\': '\\',
  # '/':  '/',
  # b:    '\b',
  # f:    '\f',
  # n:    '\n',
  # r:    '\r',
  # t:    '\t'
  
end