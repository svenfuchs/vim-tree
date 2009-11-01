module FsTree
  class Vim
    extend Forwardable

    COMMANDS = {
      :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
      :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
    }

    attr_reader :window
    def_delegator :window, :buffer

    def initialize(window)
      @window = window
      @current_line = 0

      create_window if $fs_window.nil?
      init_buffer
      map_keys
      lock
      # hide_cursor
    end

    def can_sync?
      !focussed? && !no_winenter?
    end

    def focussed?
      $curwin == window
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
      previous!
      mode = :split if mode == :normal && modified?
      command = buffer_command(path, mode) || file_command(path, mode)
      exe "silent #{command}"
      # previous!
    end

    def buffer_command(path, mode)
      if buffer = find_buffer(path)
        "#{COMMANDS[:buff][mode]} #{buffer.number}"
      end
    end

    def file_command(path, mode)
      path = VIM.filename_escape(path)
      "#{COMMANDS[:file][mode]} #{path}"
    end

    def line
      buffer.line_number - 1
    end

    def move_up(distance = 1)
      move_to(line - distance)
    end

    def move_down(distance = 1)
      move_to(line + distance)
    end

    def move_to(line)
      window.cursor = [line + 1, window.cursor[1]]
    end

    def draw(lines)
      in_fs_window do
        unlocked do
          maintain_line_number do
            clear
            lines.each { |line| append(line) }
            buffer.delete(buffer.length)
            # move_to(line)
          end
        end
      end
    end

    protected

      def modified?
        VIM.evaluate('&modified') == '1'
      end

      def previous!
        no_winenter do
          exe('wincmd p')
        end
      end

      def find_buffer(path)
        i = 0
        while i < VIM::Buffer.count
          buffer = VIM::Buffer[i]
          return buffer if path == buffer.name
          i += 1
        end
      end

      def clear
        @current_line = 0
        # exe "silent %d _"
        i = 0
        length = buffer.length
        while i < length
          buffer.delete(buffer.length)
          i += 1
        end
      end

      def append(line)
        line = " #{line}" # .ljust(window.width + 2)
        buffer.append(@current_line, line)
        @current_line += 1
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

      def maintain_line_number(&block)
        line = self.line
        yield
        move_to(line)
      end

      def in_fs_window(&block)
        in_window(window, &block)
      end

      def in_window(window, &block)
        $curwin == window ? yield : no_winenter do
          current = $curwin
          window.focus
          yield
          current.focus
        end
      end

      def no_winenter(&block)
        return if no_winenter?
        @no_winenter = true
        yield
        @no_winenter = false
      end

      def no_winenter?
        !!@no_winenter
      end

      def hide_cursor
        # exe "normal! Gg$" doesn't work
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
        exe ':au BufEnter * call FsTreeSync(expand("%:p"))'
        # exe "au WinEnter * call FsTreeSync(expand('%'))"
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
        map_key  :CR, :click
        map_char :K,  :page_up
        map_char :J,  :page_down
        map_char :s,  :split
        map_char :v,  :vsplit
        map_char :c,  :cwd
        map_char :C,  :cwd_root
        map_char :u,  :expand
        map_char :d,  :collapse
        map_char :R,  :refresh
        map "<leftrelease> :call FsTreeAction('click')"
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
