module FsTree
  class File < Node
    def open?
      false
    end

    def loaded?
      Vim::Window.loaded?(path)
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
      '  ' * level + "  #{name}" + (loaded? ? ' ·' : '')
    end
  end
end
