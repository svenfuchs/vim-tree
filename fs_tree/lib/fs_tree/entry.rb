module FsTree
  class Entry
    class << self
      def build(path, *args)
        ::File.directory?(path) ? Directory.new(path, *args) : File.new(path, *args)
      end
    end

    attr_accessor :path, :parent, :level

    def initialize(path, parent, state)
      @path = path
      @parent = parent
    end

    def level
      @level ||= parent ? parent.level + 1 : 0
    end

    def directory?
      is_a?(Directory)
    end

    def file?
      is_a?(File)
    end

    def name
      @name = ::File.basename(path)
    end

    def to_s
      level * ' '
    end
  end
end
