module FsTree
  class Node
    class << self
      def build(path, *args)
        klass = ::File.directory?(path) ? Directory : File
        klass.new(path, *args)
      end
    end

    attr_accessor :path, :parent, :level

    def initialize(path, parent = nil, state = :open)
      @path = path
      @parent = parent
    end

    def name
      @name = ::File.basename(path)
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

    def first_sibling?
      first_sibling == self
    end

    def first_sibling
      parent.nil? ? self : parent.children.first
    end

    def last_sibling?
      last_sibling == self
    end

    def last_sibling
      parent.nil? ? self : parent.children.last
    end

    def to_s
      level * ' '
    end

    def ==(other)
      self.path == other.path if other
    end

    def <=>(other)
      case true
      when directory? && other.directory?, file? && other.file?
        path <=> other.path
      when directory?
        -1
      else
        1
      end
    end
  end
end
