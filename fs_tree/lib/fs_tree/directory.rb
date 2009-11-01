module FsTree
  class Directory < Node
    include Enumerable

    attr_accessor :state

    def initialize(path, parent = nil, state = :open)
      super
      @state = state
    end

    def local?(path)
      ::File.exists?(path) && path.starts_with?(self.path)
    end

    def find(path)
      paths = path.sub("#{self.path}/", '').split('/')
      path  = "#{self.path}/#{paths.shift}"
      open if child = children.detect { |child| child.path == path }
      paths.empty? ? child : child && child.find(paths.join('/'))
    end

    def each(&block)
      open? ? children.each(&block) : []
    end

    def children
      @children ||= Dir["#{path}/*"].map do |path|
        Node.build(path, self, :closed)
      end.sort
    end

    def reset
      @children = nil
    end

    def flatten
      [self] + map { |child| child.flatten }.flatten
    end

    def open
      @state = :open
    end

    def close
      @state = :closed
    end

    def open?
      @state == :open
    end

    def level=(level)
      super
      @children.each { |child| child.level = level + 1 } if @children
    end

    def to_s
      '  ' * level + "#{handle} #{name}"
    end

    def handle
      open? ? '▾' : '▸'
      # open? ? '▼' : '▶'
      # open? ? '▽' : '▷'
    end
  end
end
