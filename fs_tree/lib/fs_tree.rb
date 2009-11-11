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
      return $fs_window if $fs_window && $fs_window.valid?
      window = create_window(path)
      init_buffer
      init_highlighting
      init_keys
      window.render
      window.lock
      window.cwd_root
      window
    end

    def create_window(path)
      exe "silent! topleft vnew #{@title}"
      exe "vertical resize 30"
      window = Vim::Window[0]
      window.extend(Window)
      window.init(path)
      window
    end

    def init_buffer
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
      exe ':au BufEnter * call FsTreeSync(expand("%:p"))' # FocusGained ?
      # exe ':au SessionLoadPost call FsTreeSessionLoaded()'
    end

    def init_highlighting
      exe 'syn match fsTree ".*"'
      exe 'syn match fsDir             "^.*\(▸\|▾\).*$"      contains=fsDirHandle,fsDirOpen'
      exe 'syn match fsDirOpen         "^.*▾.*$"             contains=fsDirHandleOpen'
      exe 'syn match fsDirClosed       "^.*▸.*$"             contains=fsDirHandleClosed'
      exe 'syn match fsDirHandle       contained "\(▸\|▾\)+" contains=fsDirHandleOpen,fsDirHandleClosed'
      exe 'syn match fsDirHandleOpen   contained "▾"'
      exe 'syn match fsDirHandleClosed contained "▸"'
      exe 'syn match fsBufferLoaded    "^.*·.*$" contains=fsDot'
      exe 'syn match fsDot             contained "·"'
      exe 'hi def link fsDot           Ignore'
      exe 'hi def link fsBufferLoaded  Identifier'
      # exe "hi Cursor gui=NONE guifg=NONE guibg=NONE"
      # let b:current_syntax = "fs_tree"
      # exe "color fs_tree"
    end

    def init_keys
      map_key  :left,      :left
      map_key  :right,     :right
      map_key  :'s-left',  :shift_left
      map_key  :'s-right', :shift_right

      map_char :h,  :left
      map_char :l,  :right
      map_char :H,  :shift_left
      map_char :L,  :shift_right
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
      map_char :q,  :quit

      # map <a-leftmouse> # only activate window
      map "<leftrelease> :call FsTreeAction('click')"
    end

    # def cleanup
    #   # remove autocommand BufEnter ?
    #   $fs_tree = nil
    # end

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
