module Vim
  class Window
    extend Forwardable

    class << self
      include Enumerable

      def each(&block)
        i = 0
        while i < count
          yield(self[i])
          i += 1
        end
      end

      def index(window)
        each_with_index { |w, ix| return ix if w == window }
        nil
      end

      def find(path)
        detect { |window| window.buffer.name == path }
      end
    end

    attr_reader :vim
    def_delegators :vim, :focussed?, :exe, :eval

    def init(vim = nil)
      @vim = vim
    end

    def number
      @number ||= Window.index(self)
    end

    def line
      buffer.line_number - 1
    end

    def move_to(line)
      self.cursor = [line + 1, cursor[1]]
    end

    def move_up(distance = 1)
      move_to(line - distance)
    end

    def move_down(distance = 1)
      move_to(line + distance)
    end

    def render(lines)
      focussed do
        unlocked do
          maintain_line do
            buffer.clear
            lines.each_with_index { |line, ix| buffer.append(ix, line) }
            buffer.delete(buffer.length)
          end
        end
      end
    end

    def unlocked(&block)
      unlock
      yield
      lock
    end

    def lock
      focussed { exe "setlocal nomodifiable" }
    end

    def unlock
      focussed { exe "setlocal modifiable" }
    end

    def focussed?
      $curwin == self
    end

    def focussed(&block)
      $curwin == self ? yield : begin
        current = $curwin
        vim.focus(self)
        result = yield
        vim.focus(current)
        result
      end
    end

    def maintain_window(&block)
      current = $curwin
      yield
      vim.focus(current)
    end

    def maintain_line(&block)
      line = self.line
      yield
      move_to(line)
    end

    def hide_cursor
      # vim.exe "normal! Gg$" doesn't work
    end
  end
end
