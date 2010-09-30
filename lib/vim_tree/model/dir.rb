module VimTree
  module Model
    class Dir < Node
      include Enumerable

      attr_accessor :state

      def initialize(path, parent = nil, state = :closed)
        @state = state
        super(path, parent)
      end

      def move_out
        close(:recursive => true)
        reset(dirname)
        open
      end

      def move_in(node)
        reset(node) if node.directory?
      end

      def [](ix)
        flatten[ix]
      end

      def find(path)
        flatten.detect { |node| node.to_s == path }
      end

      def index(node)
        flatten.index(node)
      end

      def each(&block)
        open? ? children.each(&block) : []
      end

      def children
        @children ||= Pathname.glob(join('*')).map do |path|
          Node.build(path, self)
        end.sort
      end

      def dirs
        children.select { |child| child.directory? }
      end

      def flatten
        [self] + map { |node| node.respond_to?(:flatten) ? node.flatten : node }.compact.flatten
      end

      def toggle
        open? ? close : open
      end

      def open(options = {})
        self.state = :open
        each { |node| node.open(options) if node.directory? } if options[:recursive]
      end

      def close(options = {})
        each { |node| node.close(options) if node.directory? } if options[:recursive]
        @state = :closed
      end

      def open?
        state == :open
      end

      def reset(root = nil)
        # maintain_status do
          @path = root.to_s if root
          @children = nil
        # end
      end

      def maintain_status(&block)
        paths = select { |node| node.directory? && node.open? }.map(&:to_s)
        paths.unshift(to_s) if open?
        yield
        paths.each { |path| node = find(path) and node.open }
      end
    end
  end
end
