require "minitest/autorun"
require_relative "../lib/mdsmith/token"
require_relative "../lib/mdsmith/lexer"

class TestLexer < Minitest::Test
  def test_tokenize_heading_level_1
    lexer = Mdsmith::Lexer.new("# Title")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :heading, tokens[0].type
    assert_equal "Title", tokens[0].value
    assert_equal 1, tokens[0].metadata[:level]
  end

  def test_tokenize_heading_level_2
    lexer = Mdsmith::Lexer.new("## Subtitle")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :heading, tokens[0].type
    assert_equal "Subtitle", tokens[0].value
    assert_equal 2, tokens[0].metadata[:level]
  end

  def test_tokenize_heading_level_6
    lexer = Mdsmith::Lexer.new("###### Small heading")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :heading, tokens[0].type
    assert_equal "Small heading", tokens[0].value
    assert_equal 6, tokens[0].metadata[:level]
  end

  def test_tokenize_text
    lexer = Mdsmith::Lexer.new("This is a paragraph.")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :text, tokens[0].type
    assert_equal "This is a paragraph.", tokens[0].value
  end

  def test_tokenize_empty_line
    lexer = Mdsmith::Lexer.new("\n")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :newline, tokens[0].type
    assert_equal "\n", tokens[0].value
  end

  def test_tokenize_multiple_lines
    markdown = <<~MD
      # Title
      This is text.
      ## Subtitle
    MD

    lexer = Mdsmith::Lexer.new(markdown)
    tokens = lexer.tokenize

    assert_equal 3, tokens.length

    assert_equal :heading, tokens[0].type
    assert_equal "Title", tokens[0].value
    assert_equal 1, tokens[0].metadata[:level]

    assert_equal :text, tokens[1].type
    assert_equal "This is text.", tokens[1].value

    assert_equal :heading, tokens[2].type
    assert_equal "Subtitle", tokens[2].value
    assert_equal 2, tokens[2].metadata[:level]
  end

  def test_tokenize_heading_with_extra_spaces
    lexer = Mdsmith::Lexer.new("#   Title with spaces   ")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :heading, tokens[0].type
    assert_equal "Title with spaces", tokens[0].value
  end

  def test_tokenize_text_with_leading_trailing_spaces
    lexer = Mdsmith::Lexer.new("   Text with spaces   ")
    tokens = lexer.tokenize

    assert_equal 1, tokens.length
    assert_equal :text, tokens[0].type
    assert_equal "Text with spaces", tokens[0].value
  end

  def test_tokenize_empty_string
    lexer = Mdsmith::Lexer.new("")
    tokens = lexer.tokenize

    assert_equal 0, tokens.length
  end

  def test_tokenize_with_blank_lines
    markdown = <<~MD
      # Title

      Text after blank line
    MD

    lexer = Mdsmith::Lexer.new(markdown)
    tokens = lexer.tokenize

    assert_equal 3, tokens.length
    assert_equal :heading, tokens[0].type
    assert_equal :newline, tokens[1].type
    assert_equal :text, tokens[2].type
  end
end
