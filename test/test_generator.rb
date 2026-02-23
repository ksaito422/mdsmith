require "minitest/autorun"
require_relative "../lib/mdsmith/node"
require_relative "../lib/mdsmith/generator"

class TestGenerator < Minitest::Test
  def wrap_html(body_content)
    header = <<~HTML
      <!DOCTYPE html>
      <html lang="ja">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
      </head>
      <body>
    HTML
    footer = <<~HTML
      </body>
      </html>
    HTML
    header + body_content + "\n" + footer
  end

  def test_generate_empty_document
    ast = Mdsmith::Node.new(:document)
    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html(""), html
  end

  def test_generate_heading_level_1
    ast = Mdsmith::Node.new(:document)
    heading = Mdsmith::Node.new(:heading, level: 1, content: "Title")
    ast.add_child(heading)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<h1>Title</h1>"), html
  end

  def test_generate_heading_level_2
    ast = Mdsmith::Node.new(:document)
    heading = Mdsmith::Node.new(:heading, level: 2, content: "Subtitle")
    ast.add_child(heading)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<h2>Subtitle</h2>"), html
  end

  def test_generate_heading_level_6
    ast = Mdsmith::Node.new(:document)
    heading = Mdsmith::Node.new(:heading, level: 6, content: "Small")
    ast.add_child(heading)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<h6>Small</h6>"), html
  end

  def test_generate_paragraph
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: "This is text.")
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>This is text.</p>"), html
  end

  def test_generate_multiple_nodes
    ast = Mdsmith::Node.new(:document)
    heading = Mdsmith::Node.new(:heading, level: 1, content: "Title")
    paragraph = Mdsmith::Node.new(:paragraph, content: "Text")
    ast.add_child(heading)
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<h1>Title</h1>\n<p>Text</p>"), html
  end

  def test_escape_ampersand
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: "A & B")
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>A &amp; B</p>"), html
  end

  def test_escape_less_than
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: "1 < 2")
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>1 &lt; 2</p>"), html
  end

  def test_escape_greater_than
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: "2 > 1")
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>2 &gt; 1</p>"), html
  end

  def test_escape_double_quote
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: 'Say "hello"')
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>Say &quot;hello&quot;</p>"), html
  end

  def test_escape_single_quote
    ast = Mdsmith::Node.new(:document)
    paragraph = Mdsmith::Node.new(:paragraph, content: "It's fine")
    ast.add_child(paragraph)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<p>It&#39;s fine</p>"), html
  end

  def test_escape_multiple_special_chars
    ast = Mdsmith::Node.new(:document)
    heading = Mdsmith::Node.new(:heading, level: 1, content: "<script>alert('XSS')</script>")
    ast.add_child(heading)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    assert_equal wrap_html("<h1>&lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;</h1>"), html
  end

  def test_generate_complex_document
    ast = Mdsmith::Node.new(:document)
    h1 = Mdsmith::Node.new(:heading, level: 1, content: "Main Title")
    p1 = Mdsmith::Node.new(:paragraph, content: "First paragraph.")
    h2 = Mdsmith::Node.new(:heading, level: 2, content: "Subtitle")
    p2 = Mdsmith::Node.new(:paragraph, content: "Second paragraph.")

    ast.add_child(h1)
    ast.add_child(p1)
    ast.add_child(h2)
    ast.add_child(p2)

    generator = Mdsmith::Generator.new(ast)
    html = generator.generate

    expected_body = "<h1>Main Title</h1>\n<p>First paragraph.</p>\n<h2>Subtitle</h2>\n<p>Second paragraph.</p>"
    assert_equal wrap_html(expected_body), html
  end

  def test_generate_simple_list
    ast = Mdsmith::Node.new(:document)
    ul = Mdsmith::Node.new(:unordered_list)
    ul.add_child(Mdsmith::Node.new(:list_item, content: "apple"))
    ul.add_child(Mdsmith::Node.new(:list_item, content: "banana"))
    ast.add_child(ul)

    html = Mdsmith::Generator.new(ast).generate

    expected_body = "<ul>\n  <li>apple</li>\n  <li>banana</li>\n</ul>"
    assert_equal wrap_html(expected_body), html
  end

  def test_generate_list_item_has_indentation
    ast = Mdsmith::Node.new(:document)
    ul = Mdsmith::Node.new(:unordered_list)
    ul.add_child(Mdsmith::Node.new(:list_item, content: "item"))
    ast.add_child(ul)

    html = Mdsmith::Generator.new(ast).generate

    assert_match(/^  <li>/, html)
  end

  def test_generate_nested_list
    ast = Mdsmith::Node.new(:document)
    ul = Mdsmith::Node.new(:unordered_list)

    fruit = Mdsmith::Node.new(:list_item, content: "fruit")
    sub_ul = Mdsmith::Node.new(:unordered_list)
    sub_ul.add_child(Mdsmith::Node.new(:list_item, content: "apple"))
    fruit.add_child(sub_ul)

    ul.add_child(fruit)
    ul.add_child(Mdsmith::Node.new(:list_item, content: "vegetable"))
    ast.add_child(ul)

    html = Mdsmith::Generator.new(ast).generate

    expected_body = "<ul>\n  <li>fruit\n    <ul>\n      <li>apple</li>\n    </ul>\n  </li>\n  <li>vegetable</li>\n</ul>"
    assert_equal wrap_html(expected_body), html
  end

  def test_generate_list_escapes_html
    ast = Mdsmith::Node.new(:document)
    ul = Mdsmith::Node.new(:unordered_list)
    ul.add_child(Mdsmith::Node.new(:list_item, content: "<script> & \"test\""))
    ast.add_child(ul)

    html = Mdsmith::Generator.new(ast).generate

    assert_includes html, "&lt;script&gt; &amp; &quot;test&quot;"
  end
end
