module Vim
  class Window
    class << self
      include Vim, Enumerable

      attr_accessor :previous

      def each(&block)
        i = 0
        while i < count
          yield(self[i])
          i += 1
        end
      end

      def last
        self[count - 1]
      end

      def index(window)
        each_with_index { |w, ix| return ix if w == window }
        nil
      end

      def find(path)
        detect { |window| window.buffer && window.buffer.name == path.to_s }
      end

      def open?(path)
        !!find(path)
      end

      # def previous!
      #   block_events { cmd('wincmd p') }
      # end

      # def previous
      #   previous!
      #   $curwin.tap { previous! }
      # end

      def previous!
        block_events { cmd('wincmd p') }
      end
    end

    include Vim

    def index
      self.class.index(self)
    end

    def number
      index ? index + 1 : nil
    end

    def close
      focus
      cmd "wincmd q"
    end

    def valid?
      focussed { !!buffer.line_number } rescue false
    end

    def can_load?
      modified? && !modifiable?
    end

    def modified?
      focussed { eval('&modified') == '1' }
    end

    def modifiable?
      focussed { eval('&modifiable') == '1' }
    end

    def focus
      Vim.block_events { cmd "#{number} wincmd w" }
    end

    def focussed?
      $curwin == self
    end

    def focussed(&block)
      $curwin == self ? yield : Vim.block_events do
        current = $curwin
        focus
        result = yield
        current.focus
        result
      end
    end

    def unlocked(&block)
      focussed do
        unlock
        yield
        lock
      end
    end

    def lock
      focussed { cmd "setlocal nomodifiable" }
    end

    def unlock
      focussed { cmd "setlocal modifiable" }
    end

    def maintain_cursor
      cursor = self.cursor
      yield
      self.cursor = cursor
    end

    def maintain_window(&block)
      current = $curwin
      focus
      yield
      current.focus
    end

    def maintain_line(&block)
      line = self.line
      yield
      move_to(dir.index(line)) if line
    end
  end
end
