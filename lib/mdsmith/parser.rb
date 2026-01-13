module Mdsmith
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def parse
      root = Node.new(:document)

      @tokens.each do |token|
        case token.type
        when :heading
          node = Node.new(:heading, level: token.metadata[:level], content: token.value)
          root.add_child(node)
        when :text
          node = Node.new(:paragraph, content: token.value)
          root.add_child(node)
        when :newline
          # TODO: 改行をいい感じに処理したい
        end
      end

      root
    end
  end
end
