module FsTree
  class File < Entry
    def open?
      false
    end

    def dirname
      ::File.dirname(path)
    end

    def map
      []
    end

    def to_a
      []
    end

    def to_s
      '  ' * level + "  #{name}"
    end
  end
end
