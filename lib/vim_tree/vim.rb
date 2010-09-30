require 'vim_tree/vim/buffer'
require 'vim_tree/vim/window'

module Vim
  COMMANDS = {
    :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
    :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
  }
  
  class << self
    attr_accessor :last_window

    def quit_vim_tree
      $vim_tree = nil
      exe "wincmd q"
    end

    def cwd(path)
      exe "cd #{path.to_s}"
    end

    def split(path)
      open(path, :split)
    end

    def vsplit(path)
      open(path, :vsplit)
    end
    
    def open(path, mode = :normal)
      if mode == :normal && window = Window.find(path)
        focus(window)
      elsif mode == :normal and !can_load?(last_window)
        open(path, :split)
      elsif buffer = Buffer.find(path)
        focus(last_window)
        exe "#{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        focus(last_window)
        exe "#{COMMANDS[:file][mode]} #{escape(path)}"
      end
    end

    def previous!
      block_events { exe('wincmd p') }
    end

    def previous
      previous!
      $curwin.tap { previous! }
    end

    def focus(window)
      block_events { exe "#{window.number} wincmd w" }
    end

    def focussed?(window)
      $curwin == window
    end
    
    def focussed(window, &block)
      $curwin == window ? yield : block_events do
        current = $curwin
        focus(window)
        result = yield
        focus(current)
        result
      end
    end

    def unlocked(window, &block)
      unlock(window)
      yield
      lock(window)
    end

    def lock(window)
      focussed(window) { exe "setlocal nomodifiable" }
    end

    def unlock(window)
      focussed(window) { exe "setlocal modifiable" }
    end

    def can_load?(window)
      modified?(window) && !modifiable?(window)
    end
    
    def modified?(window)
      focussed(window) { eval('&modified') == '1' }
    end
    
    def modifiable?(window)
      focussed(window) { eval('&modifiable') == '1' }
    end

    def block_events(&block)
      with_setting(:eventignore, 'all', &block)
    end

    def with_setting(name, value, &block)
      old = set(name, value)
      yield
      set(name, old)
    end

    def set(name, value)
      old = eval("&#{name}")
      exe "set #{name}=#{value}"
      old
    end

    def exe(s)
      Vim.command(s)
    end

    def eval(s)
      Vim.evaluate(s)
    end

    # Escape slashes, open square braces, spaces, sharps, and double quotes.
    def escape(string)
      string.to_s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
    end
  end
end