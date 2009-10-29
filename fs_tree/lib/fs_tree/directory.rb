module FsTree
  class Directory < Entry
    attr_accessor :state

    def initialize(path, parent = nil, state = :open)
      super
      @state = state
    end

    def each(&block)
      open? ? children.each(&block) : []
    end

    def map(&block)
      open? ? children.map(&block) : []
    end

    def children
      @children ||= Dir["#{path}/*"].map do |path|
        Entry.build(path, self, :closed)
      end
    end

    def reset
      @children = nil
    end

    def to_a
      map { |child| [child] + child.to_a }.flatten
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
      children.each { |child| child.level = level + 1 }
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
