module Vim
  class Window
    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

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
        detect { |window| window.buffer && window.buffer.name == path.to_s }
      end

      def open?(path)
        !!find(path)
      end
    end

    include Vim

    def valid?
      focussed { !!buffer.line_number } rescue false
    end

    def index
      Window.index(self)
    end

    def number
      index ? index + 1 : nil
    end

    def split(path)
      open(path, :split)
    end

    def vsplit(path)
      open(path, :vsplit)
    end

    def open(path, mode = :normal)
      if mode == :normal && window = Window.find(path)
        window.focus
      elsif mode == :normal and !VimTree.last_window.can_load?
        open(path, :split)
      elsif buffer = Buffer.find(path)
        VimTree.last_window.focus
        cmd "#{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        VimTree.last_window.focus
        cmd "#{COMMANDS[:file][mode]} #{escape(path)}"
      end
    end

    def close
      focus
      cmd "wincmd q"
    end

    def focus
      Vim.block_events { Vim.cmd "#{number} wincmd w" }
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
      unlock
      yield
      lock
    end

    def lock
      focussed { Vim.cmd "setlocal nomodifiable" }
    end

    def unlock
      focussed { Vim.cmd "setlocal modifiable" }
    end

    def can_load?
      modified? && !modifiable?
    end

    def modified?
      focussed { Vim.eval('&modified') == '1' }
    end

    def modifiable?
      focussed { Vim.eval('&modifiable') == '1' }
    end

    def width
      eval("winwidth(#{VimTree.window.number})").to_i
    end
  end
end
