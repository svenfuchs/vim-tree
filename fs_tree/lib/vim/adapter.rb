require 'vim/window'
require 'vim/buffer'

module Vim
  class Adapter
    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

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
      if mode == :normal && window = Window.find(path)
        focus(window)
      elsif mode == :normal && (modified? || !modifiable?)
        open(path, :split)
      elsif buffer = Buffer.find(path)
        previous!
        exe "#{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        previous!
        exe "#{COMMANDS[:file][mode]} #{escape(path)}"
      end
    end

    def focus(window)
      block_events do
        exe "wincmd w" until $curwin == window
      end
    end

    def previous!
      block_events { exe('wincmd p') }
    end

    def modified?
      eval('&modified') == '1' # should make sure that we're on the correct window
    end

    def modifiable?
      eval('&modifiable') == '1' # should make sure that we're on the correct window
    end

    def block_events(&block)
      old = set(:eventignore, 'all')
      yield
      set(:eventignore, old)
    end

    def blocked?(event)
      !!@blocked[event]
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

    def buffer_command(path, mode)
      if buffer = Vim::Buffer.find(path)
        "#{COMMANDS[:buff][mode]} #{buffer.number}"
      end
    end

    def file_command(path, mode)
      path = filename_escape(path)
      "#{COMMANDS[:file][mode]} #{path}"
    end

    def escape(s)
      # Escape slashes, open square braces, spaces, sharps, and double quotes.
      s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
    end
  end
end
