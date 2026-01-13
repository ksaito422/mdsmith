module Mdsmith
  class Generator
    def initialize(ast)
      @ast = ast
    end

    def generate
      render_node(@ast)
    end

    private

    def render_node(node)
      case node.type
      when :document
        node.children.map { |child| render_node(child) }.join("\n")
      when :heading
        level = node.attributes[:level]
        content = node.text_content
        "<h#{level}>#{escape_html(content)}</h#{level}>"
      when :paragraph
        "<p>#{escape_html(node.text_content)}</p>"
      else
        ''
      end
    end

    def escape_html(text)
      text.gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&#39;')
    end
  end
end
