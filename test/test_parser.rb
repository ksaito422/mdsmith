require "minitest/autorun"
require_relative "../lib/mdsmith/token"
require_relative "../lib/mdsmith/node"
require_relative "../lib/mdsmith/parser"

class TestParser < Minitest::Test
  def test_parse_empty_tokens
    parser = Mdsmith::Parser.new([])
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 0, ast.children.length
  end

  def test_parse_single_heading
    tokens = [
      Mdsmith::Token.new(:heading, "Title", level: 1)
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 1, ast.children.length

    heading = ast.children[0]
    assert_equal :heading, heading.type
    assert_equal 1, heading.attributes[:level]
    assert_equal "Title", heading.attributes[:content]
  end

  def test_parse_single_paragraph
    tokens = [
      Mdsmith::Token.new(:text, "This is a paragraph.")
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 1, ast.children.length

    paragraph = ast.children[0]
    assert_equal :paragraph, paragraph.type
    assert_equal "This is a paragraph.", paragraph.attributes[:content]
  end

  def test_parse_heading_and_paragraph
    tokens = [
      Mdsmith::Token.new(:heading, "Title", level: 1),
      Mdsmith::Token.new(:text, "Some text.")
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 2, ast.children.length

    assert_equal :heading, ast.children[0].type
    assert_equal :paragraph, ast.children[1].type
  end

  def test_parse_multiple_headings
    tokens = [
      Mdsmith::Token.new(:heading, "Title", level: 1),
      Mdsmith::Token.new(:heading, "Subtitle", level: 2),
      Mdsmith::Token.new(:heading, "Another", level: 3)
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 3, ast.children.length

    assert_equal 1, ast.children[0].attributes[:level]
    assert_equal 2, ast.children[1].attributes[:level]
    assert_equal 3, ast.children[2].attributes[:level]
  end

  def test_parse_ignores_newline_tokens
    tokens = [
      Mdsmith::Token.new(:heading, "Title", level: 1),
      Mdsmith::Token.new(:newline, "\n"),
      Mdsmith::Token.new(:text, "Text")
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal :document, ast.type
    assert_equal 2, ast.children.length
    assert_equal :heading, ast.children[0].type
    assert_equal :paragraph, ast.children[1].type
  end

  def test_parse_preserves_heading_levels
    tokens = [
      Mdsmith::Token.new(:heading, "H1", level: 1),
      Mdsmith::Token.new(:heading, "H2", level: 2),
      Mdsmith::Token.new(:heading, "H6", level: 6)
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal 1, ast.children[0].attributes[:level]
    assert_equal 2, ast.children[1].attributes[:level]
    assert_equal 6, ast.children[2].attributes[:level]
  end

  def test_parse_preserves_content
    tokens = [
      Mdsmith::Token.new(:heading, "Special & <chars>", level: 1),
      Mdsmith::Token.new(:text, "Text with \"quotes\"")
    ]

    parser = Mdsmith::Parser.new(tokens)
    ast = parser.parse

    assert_equal "Special & <chars>", ast.children[0].attributes[:content]
    assert_equal "Text with \"quotes\"", ast.children[1].attributes[:content]
  end
end
