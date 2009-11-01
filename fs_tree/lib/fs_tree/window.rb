module FsTree
  class Window
    extend Forwardable

    attr_reader :vim, :list

    def_delegators :list, :root
    def_delegators :vim, :line
    def_delegators :current, :path, :parent, :directory?, :file?, :open?,
                   :first_sibling?, :first_sibling, :last_sibling?, :last_sibling

    def initialize(vim, path)
      @vim = vim
      @list = List.new(path)
      @line = 0
      render
    end

    def action(action)
      send(action) if respond_to?(action)
    end

    def sync(path)
      if vim.can_sync? && ix = list.find(path)
        vim.move_to(ix)
        render
      end
    end

    def cwd_root
      vim.cwd(root.path)
    end

    def cwd
      vim.cwd(current.path) if directory?
    end

    def expand
      maintain_current_entry do
        @list.expand
        render
      end
    end

    def collapse
      list.collapse(line)
      render
      vim.move_to(0)
    end

    def click
      directory? ? toggle : vim.open(path)
    end

    def split
      vim.split(path) if file?
    end

    def vsplit
      vim.vsplit(path) if file?
    end

    def left
      open? ? close : close_parent
    end

    def right
      if directory?
        open
        vim.move_down
      else
        vim.open(path)
      end
    end

    def page_up
      target = first_sibling? ? parent && parent.first_sibling : first_sibling
      vim.move_to(index(target))
    end

    def page_down
      target = last_sibling? ? parent && parent.last_sibling : last_sibling
      vim.move_to(index(target))
    end

    protected

      def index(node = nil)
        list.index(node || current)
      end

      def current
        list[line]
      end

      def toggle
        list.toggle(line)
        render
      end

      def open
        list.open(line)
        render
      end

      def close
        list.close(line)
        render
        vim.move_to(list.index(current))
      end

      def close_parent
        ix = list.index(parent)
        list.close(ix)
        render
        vim.move_to(ix)
      end

      def refresh
        maintain_current_entry do
          @list.reset
          render
        end
      end

      def render
        vim.draw(list.map { |node| node.to_s })
      end

      def maintain_current_entry(&block)
        current = self.current
        yield
        vim.move_to(list.index(current).to_i) if current
      end
    end
end
