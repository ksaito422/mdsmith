require "minitest/autorun"
require_relative "../lib/mdsmith/node"

class TestNode < Minitest::Test
  def test_initialize_with_type
    node = Mdsmith::Node.new(:paragraph)

    assert_equal :paragraph, node.type
    assert_equal [], node.children
    assert_equal({}, node.attributes)
  end

  def test_initialize_with_attributes
    node = Mdsmith::Node.new(:heading, level: 1, content: "Title")

    assert_equal :heading, node.type
    assert_equal({ level: 1, content: "Title" }, node.attributes)
  end

  def test_add_child
    parent = Mdsmith::Node.new(:document)
    child = Mdsmith::Node.new(:paragraph, content: "Text")

    result = parent.add_child(child)

    assert_equal 1, parent.children.length
    assert_equal child, parent.children[0]
    assert_equal child, result
  end

  def test_add_multiple_children
    parent = Mdsmith::Node.new(:document)
    child1 = Mdsmith::Node.new(:heading, content: "Title")
    child2 = Mdsmith::Node.new(:paragraph, content: "Text")

    parent.add_child(child1)
    parent.add_child(child2)

    assert_equal 2, parent.children.length
    assert_equal child1, parent.children[0]
    assert_equal child2, parent.children[1]
  end

  def test_text_content_with_content_attribute
    node = Mdsmith::Node.new(:paragraph, content: "Hello World")

    assert_equal "Hello World", node.text_content
  end

  def test_text_content_without_content_attribute
    node = Mdsmith::Node.new(:document)

    assert_equal '', node.text_content
  end

  def test_children_is_empty_array_by_default
    node = Mdsmith::Node.new(:paragraph)

    assert_instance_of Array, node.children
    assert_empty node.children
  end
end
