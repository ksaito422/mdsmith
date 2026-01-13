module Mdsmith
  class Lexer
    def initialize(text)
      @text = text
      @tokens = []
    end

    def tokenize
      @text.each_line do |line|
        if line.match(/^(\#{1,6})\s+(.+)/)
          level = $1.length
          content = $2.strip
          @tokens << Token.new(:heading, content, level:)
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
