module FsTree
  class List < Array
    extend Forwardable

    def_delegators :root, :local?

    def initialize(path)
      super(Directory.new(path).flatten)
    end

    def find(path)
      if local?(path) && node = root.find(path)
        replace(root.flatten)
        index(node)
      end
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

    def open(ix, options = {})
      node = self[ix]
      unless node.open?
        node.open(options)
        self[ix, 1] = node.flatten
      end
    end

    def close(ix, options = {})
      node = self[ix]
      if node.open?
        self[ix, node.flatten.size] = [node]
        node.close(options)
      end
    end

    def reset(path = nil)
      maintain_status do
        self.root = path if path
        root.reset
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
