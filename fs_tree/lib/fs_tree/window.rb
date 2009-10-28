module FsTree
  class Window
    # class << self
    #   def select(window)
    #     return true if window == $curwin

    #     # Try to select the given window.
    #     start = $curwin
    #     exe("wincmd w") while ($curwin != window) and ($curwin != start)
    #     return true if $curwin == window

    #     # Failed -- re-select the starting window.
    #     exe("wincmd w") while $curwin != start
    #     pretty_msg("ErrorMsg", "Cannot find the correct window!")
    #     return false
    #   end
    # end

    attr_reader :window, :buffer

    def initialize(window, buffer)
      @window = window
      @buffer = buffer
      @current_line = 0

      # create_window
      init_buffer
      map_keys
      lock
      hide_cursor
    end

    def target!
      create_window if Vim::Window.count == 1
      previous!
    end

    def previous!
      exe('wincmd p')
    end

    def open(path)
      target!
      path = VIM.filename_escape(path)
      exe "silent e #{path}"
      previous!
    end

    def width
      @window.width
    end

    def height
      @window.height
    end

    def line_number
      @buffer.line_number
    end

    def line_number=(line_number)
      @window.cursor = [line_number, width + 2]
      hide_cursor
    end

    def clear
      unlocked do
        @current_line = 0
        exe "silent %d _"
      end
    end

    def append(line)
      unlocked do
        line = " #{line}".ljust(@window.width + 3) + ' '
        buffer.append(@current_line, line)
        @current_line += 1
      end
    end

    def unlocked(&block)
      unlock
      yield
      lock
    end

    def lock
      exe "setlocal nomodifiable"
    end

    def unlock
      exe "setlocal modifiable"
    end

    def hide_cursor
      exe "normal! 0" # hides the cursor
    end

    def create_window
      exe "silent! botright vnew #{@title}"
      previous!
      exe "vertical resize 30"
    end

    def init_buffer
      # stolen from lusty-explorer
      exe "setlocal bufhidden=delete"
      exe "setlocal buftype=nofile"
      exe "setlocal noswapfile"
      exe "setlocal nowrap"
      exe "setlocal nonumber"
      exe "setlocal foldcolumn=0"
      exe "setlocal cursorline"
      exe "setlocal nospell"
      exe "setlocal nobuflisted"
      exe "setlocal textwidth=0"
      exe "set timeoutlen=0"
      exe "set noinsertmode"
      exe "set noshowcmd"
      exe "set nolist"
      exe "set report=9999"
      exe "set sidescroll=0"
      exe "set sidescrolloff=0"
      # exe "highlight Cursor gui=NONE guifg=NONE guibg=NONE"
      # exe 'syn match FsTree ".*"'
    end

    def map_keys
      # noop all printables
      # printables.each_byte do |b|
      #   map "<Char-#{b}> <Nop>"
      # end

      # Special characters
      # map_key :Tab
      map_key  :Left
      map_key  :Right
      map_char :h,  :left
      map_char :l,  :right
      map_key  :CR, :toggle
      map_char :R,  :refresh
      map_char :J,  :dive
      map_char :K,  :surface
    end

    def map_char(char, target = char)
      map_key :"Char-#{char.to_s.ord}", target
    end

    def map_key(key, target = key)
      map "<#{key}>  :call FsTreeAction('#{target.to_s.downcase}')"
    end

    def map(command)
      exe "noremap <silent> <buffer> #{command}<CR>"
    end

    def printables
      @printables ||= '/!"#$%&\'()*+,-.0123456789:<=>?#@"' \
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`' \
                      'abcdefghijklmnopqrstuvwxyz{}~'
    end

    def exe(s)
      VIM.command s
    end
  end
end
