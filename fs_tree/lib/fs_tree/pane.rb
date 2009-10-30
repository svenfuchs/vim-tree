module FsTree
  class Pane
    attr_reader :window, :list

    def initialize(window, list)
      @window = window
      @list = list
      @line = 0
      redraw
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
      keep_line_number do
        @list.expand
        redraw
      end
    end

    def dive
      keep_line_number do
        list.slice(line)
        redraw
      end
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
      window.keep_line_number do
        @list.reset
        redraw
      end
    end

    def redraw
      window.clear
      reset
      render
    end

    def reset
      window.line_number = 0
    end

    def render
      line_number = window.line_number
      window.clear
      list.each { |entry| window.append(entry.to_s) }
      # window.height.times { window.append('') }
      window.line_number = line_number
    end

    def keep_line_number(&block)
      _current = current
      yield
      window.line_number = list.index(_current) + 1
    end
  end
end
