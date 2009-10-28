module FsTree
  class Pane
    attr_reader :window, :list

    def initialize(window, list)
      @window = window
      @list = list
      @line = 0
    end

    def action(action)
      send(action) if respond_to?(action)
    end

    def surface
      @list.expand
      redraw
    end

    def dive
      ix = window.line_number - 1
      list.slice(ix) && redraw if list[ix]
    end

    def toggle
      ix = window.line_number - 1
      list[ix].directory? ? list.toggle(ix) && render : window.open(list[ix].path) if list[ix]
    end

    def left
      ix = window.line_number - 1
      list[ix].open? ? close(ix) : close_parent(ix) if list[ix]
    end

    def right
      ix = window.line_number - 1
      list[ix].directory? ? open(window.line_number - 1) : window.open(list[ix].path) if list[ix]
    end

    def open(ix)
      window.line_number += 1 if list.open(ix)
      render
    end

    def close(ix)
      list.close(ix)
      render
    end

    def close_parent(ix)
      ix = list.index(list[ix].parent)
      close(ix)
      window.line_number = ix + 1
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
  end
end
