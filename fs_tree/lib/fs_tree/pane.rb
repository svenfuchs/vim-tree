module FsTree
  class Pane
    attr_reader :window, :list

    def initialize(window, list)
      @window = window
      @list = list
      @line = 0
      render
    end

    def root
      list.root
    end

    def line
      window.line_number - 1
    end

    def current
      list[line]
    end

    def path
      current.path
    end

    def parent
      current.parent
    end

    def directory?
      current.directory?
    end

    def file?
      current.file?
    end

    def open?
      current.open?
    end

    def action(action)
      send(action) if respond_to?(action)
    end

    def cwd_root
      window.cwd(root.path)
    end

    def cwd
      window.cwd(current.dirname)
    end

    def surface
      maintain_current_entry do
        @list.expand
        render
      end
    end

    def dive
      list.slice(line)
      render
      window.line_number = 1
    end

    def toggle
      directory? ? list.toggle(line) && render : window.open(path) if current
    end

    def split
      window.open(path, :split) if file?
    end

    def vsplit
      window.open(path, :vsplit) if file?
    end

    def left
      open? ? close : close_parent
    end

    def right
      directory? ? open : window.open(path)
    end

    def page_up
      window.line_number = parent.children.first
    end

    def page_down
      window.line_number = parent.children.last
    end

    def open
      list.open(line) && window.line_number += 1
      render
    end

    def close
      list.close(line)
      render
    end

    def close_parent
      ix = list.index(parent)
      list.close(ix)
      render
      window.line_number = ix + 1
    end

    def refresh
      maintain_current_entry do
        @list.reset
        render
      end
    end

    def render
      window.render(list.map { |entry| entry.to_s })
    end

    def maintain_current_entry(&block)
      _current = current
      yield
      window.line_number = list.index(_current).to_i + 1 if _current
    end
  end
end
