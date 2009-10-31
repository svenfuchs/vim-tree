module FsTree
  class File < Node
    def open?
      false
    end

    def dirname
      ::File.dirname(path)
    end

    def flatten
      [self]
    end

    def to_a
      []
    end

    def to_s
      '  ' * level + "  #{name}"
    end
  end
end
