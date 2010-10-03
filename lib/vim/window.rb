module Vim
  class Window
    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

    class << self
      include Vim, Enumerable

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

      def previous!
        block_events { cmd('wincmd p') }
      end

      def previous
        previous!
        $curwin.tap { previous! }
      end
    end

    include Vim

    attr_accessor :controller

    def tree?
      singleton_class.included_modules.include?(Vim::Tree)
    end

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
      elsif mode == :normal and !Vim::Tree.last_window.can_load?
        open(path, :split)
      elsif buffer = Buffer.find(path)
        Vim::Tree.last_window.focus
        cmd "#{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        Vim::Tree.last_window.focus
        cmd "#{COMMANDS[:file][mode]} #{escape(path)}"
      end
    end

    def close
      focus
      cmd "wincmd q"
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
      focussed do
        unlock
        yield
        lock
      end
    end

    def lock
      focussed { Vim.cmd "setlocal nomodifiable" }
    end

    def unlock
      focussed { Vim.cmd "setlocal modifiable" }
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

    def width
      eval("winwidth(#{Vim::Tree.window.number})").to_i
    end
  end
end
