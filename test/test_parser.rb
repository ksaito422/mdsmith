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

  def test_parse_single_list_item
    tokens = [Mdsmith::Token.new(:list_item, "apple", depth: 0)]
    ast = Mdsmith::Parser.new(tokens).parse

    assert_equal 1, ast.children.length
    ul = ast.children[0]
    assert_equal :unordered_list, ul.type
    assert_equal 1, ul.children.length
    assert_equal :list_item, ul.children[0].type
    assert_equal "apple", ul.children[0].attributes[:content]
  end

  def test_parse_multiple_list_items_flat
    tokens = [
      Mdsmith::Token.new(:list_item, "apple",  depth: 0),
      Mdsmith::Token.new(:list_item, "banana", depth: 0),
      Mdsmith::Token.new(:list_item, "cherry", depth: 0)
    ]
    ast = Mdsmith::Parser.new(tokens).parse

    assert_equal 1, ast.children.length
    ul = ast.children[0]
    assert_equal :unordered_list, ul.type
    assert_equal 3, ul.children.length
    assert_equal "apple",  ul.children[0].attributes[:content]
    assert_equal "banana", ul.children[1].attributes[:content]
    assert_equal "cherry", ul.children[2].attributes[:content]
  end

  def test_parse_nested_list
    tokens = [
      Mdsmith::Token.new(:list_item, "fruit",  depth: 0),
      Mdsmith::Token.new(:list_item, "apple",  depth: 1),
      Mdsmith::Token.new(:list_item, "banana", depth: 1)
    ]
    ast = Mdsmith::Parser.new(tokens).parse

    ul = ast.children[0]
    assert_equal :unordered_list, ul.type
    assert_equal 1, ul.children.length

    fruit = ul.children[0]
    assert_equal "fruit", fruit.attributes[:content]
    assert_equal 1, fruit.children.length

    sub_ul = fruit.children[0]
    assert_equal :unordered_list, sub_ul.type
    assert_equal 2, sub_ul.children.length
    assert_equal "apple",  sub_ul.children[0].attributes[:content]
    assert_equal "banana", sub_ul.children[1].attributes[:content]
  end

  def test_parse_list_interrupted_by_text_creates_two_lists
    tokens = [
      Mdsmith::Token.new(:list_item, "item1", depth: 0),
      Mdsmith::Token.new(:text,      "paragraph"),
      Mdsmith::Token.new(:list_item, "item2", depth: 0)
    ]
    ast = Mdsmith::Parser.new(tokens).parse

    assert_equal 3, ast.children.length
    assert_equal :unordered_list, ast.children[0].type
    assert_equal :paragraph,      ast.children[1].type
    assert_equal :unordered_list, ast.children[2].type
  end

  def test_parse_nested_then_back_to_root
    tokens = [
      Mdsmith::Token.new(:list_item, "a",    depth: 0),
      Mdsmith::Token.new(:list_item, "a-1",  depth: 1),
      Mdsmith::Token.new(:list_item, "b",    depth: 0)
    ]
    ast = Mdsmith::Parser.new(tokens).parse

    ul = ast.children[0]
    assert_equal 2, ul.children.length
    assert_equal "a", ul.children[0].attributes[:content]
    assert_equal "b", ul.children[1].attributes[:content]
  end
end
