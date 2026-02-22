module Mdsmith
  class Generator
    def initialize(ast)
      @ast = ast
    end

    def generate
      render_node(@ast)
    end

    private

    def render_node(node, depth = 0)
      indent = "  " * depth
      case node.type
      when :document
        node.children.map { |child| render_node(child, depth) }.join("\n")
      when :heading
        level = node.attributes[:level]
        "#{indent}<h#{level}>#{escape_html(node.text_content)}</h#{level}>"
      when :unordered_list
        items = node.children.map { |child| render_node(child, depth + 1) }.join("\n")
        "#{indent}<ul>\n#{items}\n#{indent}</ul>"
      when :list_item
        content = escape_html(node.text_content)
        if node.children.any?
          sub = node.children.map { |child| render_node(child, depth + 1) }.join("\n")
          "#{indent}<li>#{content}\n#{sub}\n#{indent}</li>"
        else
          "#{indent}<li>#{content}</li>"
        end
      when :paragraph
        "#{indent}<p>#{escape_html(node.text_content)}</p>"
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
