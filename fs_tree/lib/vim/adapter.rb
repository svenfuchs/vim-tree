require 'vim/window'
require 'vim/buffer'

module Vim
  class Adapter
    extend Forwardable

    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

    attr_reader :window

    def_delegators :window, :buffer

    def initialize(window)
      @window = window
    end

    def quit
      $fs_window = nil
      exe "wincmd q"
    end

    def cwd(path)
      exe "cd #{path}"
    end

    def split(path)
      open(path, :split)
    end

    def vsplit(path)
      open(path, :vsplit)
    end

    def open(path, mode = :normal)
      previous! if focussed?
      if mode == :normal && window = Window.find(path)
        focus(window)
      elsif mode == :normal && (modified? || !modifiable?)
        open(path, :split)
      elsif buffer = Buffer.find(path)
        exe "#{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        exe "#{COMMANDS[:file][mode]} #{escape(path)}"
      end
    end

    def previous!
      block_events { exe('wincmd p') }
    end

    def focus(window)
      block_events { exe "#{window.number} wincmd w" }
    end

    def focussed?(window = $fs_window)
      $curwin == window
    end

    def focussed(&block)
      $curwin == window ? yield : begin
        current = $curwin
        focus(window)
        result = yield
        focus(current)
        result
      end
    end

    def maintain_window(&block)
      current = $curwin
      yield
      focus(current)
    end

    def modified?
      eval('&modified') == '1' # should make sure that we're on the correct window
    end

    def modifiable?
      eval('&modifiable') == '1' # should make sure that we're on the correct window
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

    def line
      buffer.line_number - 1
    end

    def move_to(line)
      window.cursor = [line + 1, window.cursor[1]]
    end

    def maintain_line(&block)
      line = window.line
      yield
      move_to(line)
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

    def hide_cursor
      # exe "normal! Gg$" doesn't work
    end

    def block_events(&block)
      with_setting(:eventignore, 'all', &block)
    end

    def with_settings(*settings, &block)
      setting = settings.pop
      if settings.empty?
        with_setting(*setting, &block)
      else
        with_settings(*settings, &lambda { with_setting(*setting, &block) })
      end
    end

    def with_setting(name, value, &block)
      old = set(name, value)
      yield
      set(name, old)
    end

    def exe(s)
      Vim.command(s)
    end

    def eval(s)
      Vim.evaluate(s)
    end

    def set(name, value)
      old = eval("&#{name}")
      exe "set #{name}=#{value}"
      old
    end

    def escape(s)
      # Escape slashes, open square braces, spaces, sharps, and double quotes.
      s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
    end
  end
end
