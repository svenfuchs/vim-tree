require 'core_ext/string/starts_with'
require 'forwardable'
require 'vim'

module FsTree
  autoload :Directory, 'fs_tree/directory'
  autoload :File,      'fs_tree/file'
  autoload :List,      'fs_tree/list'
  autoload :Node,      'fs_tree/node'
  autoload :Window,    'fs_tree/window'

  class << self
    def run(path)
      # window = $fs_window ? $fs_window : create_window(path)
      window = create_window(path)
      init_buffer
      window.render
      window.lock
      window
    end

    def create_window(path)
      exe "silent! topleft vnew #{@title}"
      exe "vertical resize 30"
      window = Vim::Window[0]
      window.extend(Window)
      window.init(path, Vim::Adapter.new)
      window
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
      # exe "setlocal laststatus=0"
      exe ':au BufEnter * call FsTreeSync(expand("%:p"))'
      # exe "au WinEnter * call FsTreeSync(expand('%'))"
      # exe "highlight Cursor gui=NONE guifg=NONE guibg=NONE"
      # exe 'syn match FsTree ".*"'

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
      VIM.command(s)
    end
  end
end
