require 'pathname'

module Vim
  module Tree
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
      end
    end
  end
end