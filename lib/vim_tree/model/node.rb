require 'pathname'

module VimTree
  module Model
    class Node < Pathname
      class << self
        def build(path, *args)
          type = path.directory? ? Dir : File
          type.new(path, *args)
        end
      end

      attr_accessor :parent, :level

      def initialize(path, parent = nil)
        @parent = parent
        super(path)
      end

      def level
        @level ||= parent ? parent.level + 1 : 0
      end
    end
  end
end