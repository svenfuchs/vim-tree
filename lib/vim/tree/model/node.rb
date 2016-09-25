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

        def touch(name)
          path = directory? ? self : dirname
          path = path.join(name)
          FileUtils.mkdir_p(path.dirname)
          FileUtils.touch(path)
        end

        def mkdir(name)
          path = directory? ? self : dirname
          path.join(name).mkpath
        end

        def cp(name)
          path = dirname.join(name)
          FileUtils.mkdir_p(path.dirname)
          FileUtils.send(directory? ? :cp_r : :cp, self, path)
        end

        def mv(name)
          path = dirname.join(name)
          FileUtils.mkdir_p(path.dirname)
          rename(path)
        end

        def rm
          directory? ? rmtree : delete
        end
      end
    end
  end
end
