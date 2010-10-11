require 'core_ext/ruby/string/ord'
require 'core_ext/ruby/kernel/singleton_class'
require 'vim'

module Vim
  module Tree
    autoload :Controller, 'vim/tree/controller'
    autoload :Model,      'vim/tree/model'
    autoload :View,       'vim/tree/view'

    WIDTH = 30

    extend Vim

    class << self
      attr_accessor :last_window

      def run(root)
        unless current && current.valid?
          cmd "silent! topleft vnew #{@title}"
          tree = Window[0]
          tree.singleton_class.send(:include, Vim::Tree, Vim::Tree::Controller)
          tree.init(root)
        end
      end

      def current
        Window.detect(&:tree?)
      end

      def store_last_window
        self.last_window = Window.previous
      end

      def valid?
        current.valid?
      end
    end

    def init(root)
      super(root)
      render

      init_window
      init_buffer
      init_highlighting
      init_keys

      Vim.cwd(root)
      update_status
      # update_tab_label
    end

    def init_window
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
      map_char :n,  :create_file
      map_char :N,  :create_dir
      map_char :p,  :cp
      map_char :m,  :mv
      map_char :r,  :rm

      # map <a-leftmouse> # only activate window
      map "<leftrelease> :call VimTreeAction('click')"
    end

    def update_status
      ix, subdirs = 1, ::Dir.getwd.split('/')
      ix += 1 until ix == subdirs.size - 1 || subdirs[-(ix + 1)..-1].join('/').size > WIDTH - 5
      status = subdirs[-ix..-1].join('/')
      status = "../#{status}" if ix < subdirs.size
      cmd "setlocal statusline=#{status.gsub('//', '/')}"
    end

    def update_tab_label
      # cmd 'set guitablabel=%{getcwd()}'
    end
  end
end
