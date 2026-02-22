module Mdsmith
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def parse
      root = Node.new(:document)

      @tokens.chunk { |t| t.type }.each do |type, group|
        case type
        when :heading
          group.each do |token|
            root.add_child(Node.new(:heading, level: token.metadata[:level], content: token.value))
          end
        when :list_item
          root.add_child(build_list(group))
        when :text
          group.each { |t| root.add_child(Node.new(:paragraph, content: t.value)) }
        when :newline
          # skip
        end
      end

      root
    end

    def build_list(tokens)
      root_list = Node.new(:unordered_list)
      stack = [root_list]
      depth_stack = [0]
      last_item = nil

      tokens.each do |token|
        depth = token.metadata[:depth]

        if depth > depth_stack.last && last_item
          new_list = Node.new(:unordered_list)
          last_item.add_child(new_list)
          stack.push(new_list)
          depth_stack.push(depth)
        elsif depth < depth_stack.last
          while depth_stack.size > 1 && depth_stack.last > depth
            stack.pop
            depth_stack.pop
          end
        end

        item = Node.new(:list_item, content: token.value)
        stack.last.add_child(item)
        last_item = item
      end

      root_list
    end
  end
end
