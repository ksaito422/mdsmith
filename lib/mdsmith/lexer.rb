module Mdsmith
  class Lexer
    def initialize(text)
      @text = text
      @tokens = []
    end

    def tokenize
      @text.each_line do |line|
        # TODO: bold/italicに対応する
        # TODO: 引用に対応する
        # TODO: コードブロックに対応する
        # TODO: リンクに対応する
        if line.match(/^(\#{1,6})\s+(.+)/)
          level = $1.length
          content = $2.strip
          @tokens << Token.new(:heading, content, level:)
        elsif line.match(/^((?:\t|  )*)([-*])\s+(.+)/)
          indent = $1
          content = $3.strip
          depth = indent.scan(/\t|  /).length
          @tokens << Token.new(:list_item, content, depth: depth)
        elsif line.strip.empty?
          @tokens << Token.new(:newline, "\n")
        else
          @tokens << Token.new(:text, line.strip)
        end
      end

      @tokens
    end
  end
end
