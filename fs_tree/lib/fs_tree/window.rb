module FsTree
  module Window
    extend Forwardable

    attr_reader :list

    def_delegators :list, :root
    def_delegators :current, :path, :parent, :directory?, :file?, :open?,
                   :first_sibling?, :first_sibling, :last_sibling?, :last_sibling

    def init(path, vim)
      super(vim)
      @list = List.new(path)
    end

    def action(action)
      send(action) if respond_to?(action)
    end

    def refresh
      maintain_entry do
        @list.reset
        render
      end
    end

    def sync(path)
      if can_sync? && ix = list.find(path)
        maintain_window do
          move_to(ix)
          render
        end
      end
    end

    def can_sync?
      !focussed? && !vim.blocked?(:winenter)
    end

    def cwd_root
      vim.cwd(root.path)
    end

    def cwd
      vim.cwd(current.path) if directory?
    end

    def expand
      maintain_entry do
        @list.expand
        render
      end
    end

    def collapse
      list.collapse(line)
      render
      move_to(0)
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
        move_down
      else
        vim.open(path)
      end
    end

    def page_up
      target = first_sibling? ? parent && parent.first_sibling : first_sibling
      move_to(index(target))
    end

    def page_down
      target = last_sibling? ? parent && parent.last_sibling : last_sibling
      move_to(index(target))
    end

    def render
      super(list.map { |node| " #{node.to_s}" })
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
        # move_to(index)
      end

      def close_parent
        move_to(index(parent))
        close
      end

      def maintain_entry(&block)
        current = self.current
        yield
        move_to(index(current).to_i) if current
      end
    end
end
