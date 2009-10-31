module FsTree
  class List < Array
    def initialize(path)
      super(Directory.new(path).flatten)
    end

    def expand
      reset(Directory.new(::File.dirname(root.path)))
    end

    def collapse(ix)
      reset(self[ix]) if self[ix].directory?
    end

    def toggle(ix)
      self[ix].open? ? close(ix) : open(ix)
    end

    def open(ix)
      node = self[ix]
      unless node.open?
        node.open
        self[ix, 1] = node.flatten
      end
    end

    def close(ix)
      node = self[ix]
      if node.open?
        self[ix, node.flatten.size] = [node]
        node.close
      end
    end

    def reset(path = nil)
      maintain_status do
        self.root = path if path
        replace(root.flatten)
      end
    end

    protected

      alias :root :first

      def root=(root)
        root.level = 0
        root.open
        root.reset
        self[0] = root
      end

      def maintain_status(&block)
        nodes = select { |node| node.open? }
        yield
        nodes.each { |node| ix = index(node) and open(ix) }
      end
  end
end
