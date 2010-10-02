require 'core_ext/ruby/string/ord'

require 'vim_tree/vim'
require 'vim_tree/vim/buffer'
require 'vim_tree/vim/buffer'

module VimTree
  autoload :Controller, 'vim_tree/controller'
  autoload :Model,      'vim_tree/model'
  autoload :View,       'vim_tree/view'

  WIDTH = 30

  extend Vim

  class << self
    attr_accessor :last_window

    def store_last_window
      self.last_window = previous
    end

    def valid?
      $vim_tree.window.valid?
    end

    def focus
      $vim_tree.window.focus
    end

    def close
      $vim_tree.window.close
      $vim_tree = nil
    end

    def update_status
      ix, subdirs = 1, ::Dir.getwd.split('/')
      ix += 1 until ix == subdirs.size - 1 || subdirs[-(ix + 1)..-1].join('/').size > WIDTH - 5
      status = subdirs[-ix..-1].join('/')
      status = "../#{status}" if ix < subdirs.size
      cmd "setlocal statusline=#{status.gsub('//', '/')}"
    end

    # init the top/leftmost window as a tree window
    # use it as a view?
    def run(root)
      return $vim_tree if $vim_tree # && $vim_tree.valid?

      Vim.cwd(root)

      init_window
      init_buffer
      init_highlighting
      init_keys
      update_status

      $vim_tree = Controller.new(Window[0], root)
      $vim_tree.render
    end

    def init_window
      cmd "silent! topleft vnew #{@title}"
      cmd "vertical resize #{WIDTH}"
    end

    def init_buffer
      cmd "setlocal bufhidden=delete"
      cmd "setlocal buftype=nofile"
      cmd "setlocal noswapfile"
      cmd "setlocal nowrap"
      cmd "setlocal nonumber"
      cmd "setlocal foldcolumn=0"
      cmd "setlocal cursorline"
      cmd "setlocal nospell"
      cmd "setlocal nobuflisted"
      cmd "setlocal textwidth=0"
      cmd "set noinsertmode"
      cmd "set noshowcmd"
      cmd "set nolist"
      cmd "set report=9999"
      cmd "set sidescroll=0"
      cmd "set sidescrolloff=0"
      cmd "setlocal winfixwidth"
      cmd ':au BufEnter * call VimTreeSync(expand("%:p"))'
      # cmd ':au SessionLoadPost call FsTreeSessionLoaded()'
    end

    def init_highlighting
      cmd 'syn match vimTree ".*"'
      cmd 'syn match vimDir             "^.*\(▸\|▾\).*$"      contains=vimDirHandle,vimDirOpen'
      cmd 'syn match vimDirOpen         "^.*▾.*$"             contains=vimDirHandleOpen'
      cmd 'syn match vimDirClosed       "^.*▸.*$"             contains=vimDirHandleClosed'
      cmd 'syn match vimDirHandle       contained "\(▸\|▾\)+" contains=vimDirHandleOpen,vimDirHandleClosed'
      cmd 'syn match vimDirHandleOpen   contained "▾"'
      cmd 'syn match vimDirHandleClosed contained "▸"'
      cmd 'syn match vimBufferLoaded    "^.*·.*$" contains=vimDot'
      cmd 'syn match vimDot             contained "·"'
      cmd 'hi def link vimDot           Ignore'
      cmd 'hi def link vimBufferLoaded  Identifier'
      # cmd "hi Cursor gui=NONE guifg=NONE guibg=NONE"
      # let b:current_syntax = "vim_tree"
      # cmd "color vim_tree"
    end

    def init_keys
      map_key  :left,      :left
      map_key  :right,     :right
      map_key  :'s-left',  :shift_left
      map_key  :'s-right', :shift_right
      map_key  :'s-up',    :page_up
      map_key  :'s-down',  :page_down

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
      map_char :i,  :move_in
      map_char :u,  :move_out
      map_char :R,  :refresh
      map_char :T,  :focus,  :buffer => false
      map_char :M,  :toggle, :buffer => false
      map_char :Q,  :quit

      # map <a-leftmouse> # only activate window
      map "<leftrelease> :call VimTreeAction('click')"
    end
  end
end
