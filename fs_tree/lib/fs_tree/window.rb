module FsTree
  class Window
    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

    attr_reader :window, :pane

    def initialize(window, root)
      @window = window
      @pane = FsTree::Pane.new(self, FsTree::List.new(root))
      @current_line = 0

      create_window if $fs_tree.nil?
      init_buffer
      map_keys
      lock
      hide_cursor
    end

    def action(action)
      pane.action(action)
    end

    def cwd(path)
      exe "cd #{path}"
    end

    def buffer
      window.buffer
    end

    def target!
      create_window if VIM::Window.count == 1
      previous!
    end

    def modified?
      VIM.evaluate('&modified') == '1'
    end

    def previous!
      exe('wincmd p')
    end

    def open(path, mode = :normal)
      target!
      mode = :split if mode == :normal && modified?
      path = VIM.filename_escape(path)
      if buffer = find_buffer(path)
        exe "silent #{COMMANDS[:buff][mode]} #{buffer.number}"
      else
        exe "silent #{COMMANDS[:file][mode]} #{path}"
      end
      # previous!
    end

    def find_buffer(path)
      i = 0
      while i < VIM::Buffer.count
        buffer = VIM::Buffer[i]
        return buffer if path == buffer.name
        i += 1
      end
    end

    def line_number
      buffer.line_number
    end

    def line_number=(line_number)
      window.cursor = [line_number, window.cursor[1]]
      hide_cursor
    end

    def render(lines)
      unlocked do
        maintain_line_number do
          clear
          lines.each { |line| append(line) }
          # (height - lines.size).times { append('') }
          buffer.delete(buffer.count)
        end
      end
    end

    def clear
      unlocked do
        @current_line = 0
        exe "silent %d _"
      end
    end

    def append(line)
      line = " #{line}".ljust(window.width + 3) + ' '
      buffer.append(@current_line, line)
      @current_line += 1
    end

    def unlocked(&block)
      unlock
      yield
      lock
    end

    def lock
      # exe "setlocal nomodifiable"
    end

    def unlock
      exe "setlocal modifiable"
    end

    def hide_cursor
      exe "normal! 0" # hides the cursor
    end

    def maintain_line_number(&block)
      _line_number = line_number
      yield
      self.line_number = _line_number
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
      exe "setlocal winfixwidth"
      # exe "highlight Cursor gui=NONE guifg=NONE guibg=NONE"
      # exe 'syn match FsTree ".*"'
    end

    def map_keys
      # noop all printables
      # printables.each_byte do |b|
      #   map "<Char-#{b}> <Nop>"
      # end

      # Special characters
      map_key  :Left
      map_key  :Right
      map_char :h,  :left
      map_char :l,  :right
      map_key  :CR, :toggle
      map_char :K,  :page_up
      map_char :J,  :page_down
      map_char :s,  :split
      map_char :v,  :vsplit
      map_char :c,  :cwd
      map_char :C,  :cwd_root
      map_char :D,  :dive
      map_char :U,  :surface
      map_char :R,  :refresh
      map "<leftrelease> :call FsTreeAction('toggle')"
    end

    def map_char(char, target = char)
      map_key :"Char-#{char.to_s.ord}", target
    end

    def map_key(key, target = key)
      map "<#{key}> :call FsTreeAction('#{target.to_s.downcase}')"
    end

    def map(command)
      exe "nnoremap <silent> <buffer> #{command}<CR>"
    end

    def exe(s)
      VIM.command s
    end
  end
end
