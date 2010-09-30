module VimTree::View
  class Base
    class << self
      def build(node)
        node.directory? ? Dir.new(node) : File.new(node)
      end
    end
    
    attr_reader :node
    
    def initialize(node)
      @node = node
    end
  end
    
  class Tree < Base
    def render
      node.flatten.map { |node| self.class.build(node) }.map(&:to_s)
    end
  end
  
  class Dir < Base
    OPEN_HANDLE   = '▾'
    CLOSED_HANDLE = '▸'
    
    def to_s
      '  ' * node.level + "#{node.open? ? OPEN_HANDLE : CLOSED_HANDLE } #{node.basename}"
    end
  end
  
  class File < Base    
    def to_s
      '  ' * node.level + "  #{node.basename}" # + (loaded? ? ' ·' : '')
    end
  end
end