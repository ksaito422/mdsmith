module Mdsmith
  class Node
    attr_reader :type, :children, :attributes

    def initialize(type, attributes = {})
      @type = type
      @children = []
      @attributes = attributes
    end

    def add_child(node)
      @children << node
      node
    end

    def text_content
      attributes[:content] || ''
    end
  end
end
