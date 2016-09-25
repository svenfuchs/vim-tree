# encoding: UTF-8

require 'core_ext/vim/vim'
require 'core_ext/vim/buffer'
require 'core_ext/vim/window'

require 'vim/tree/layout'
require 'vim/tree/window'

module Vim
  module Tree
    autoload :Controller, 'vim/tree/controller'
    autoload :Model,      'vim/tree/model'
    autoload :View,       'vim/tree/view'
    autoload :Window,     'vim/tree/window'

    WIDTH = 30

    extend Vim

    class << self
      attr_accessor :last_window

      def run(path = nil)
        if window && window.valid?
          window.focus
        else
          path = [path, $curwin.buffer.name, Dir.pwd].compact.detect { |path| !path.empty? }
          path = File.expand_path(path)
          create(path) if File.directory?(path)
        end
      end

      def create(path)
        cmd "silent! topleft vnew #{@title}"
        tree = Window[0]
        tree.singleton_class.send(:include, Vim::Tree, Vim::Tree::Controller, Vim::Tree::Layout)
        tree.init(path)
      end

      def action(*args)
        window.action(*args) if window
      end

      def toggle_focus
        window.toggle_focus if window
      end

      def sync
        window.sync_to(Vim.eval('expand("%:p")')) if window
      end

      def reload
        Dir["#{::Vim.runtime_path('vim-tree')}/lib/**/*.rb"].each { |path| load(path) }
      end

      def window
        Window.detect(&:tree?)
      end

      def store_last_window
        self.last_window = Window.previous
      end

      def valid?
        window.valid?
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
      update_window
    end

    def init_window
      cmd "vertical resize #{WIDTH}"
      cmd ':au BufWritePost * :ruby Vim::Tree.action("refresh")'
      cmd ':au BufEnter     * :ruby Vim::Tree.sync'
      # cmd ':au SessionLoadPost call FsTreeSessionLoaded()'
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
      cmd "setlocal winfixwidth"
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
      map_char :n,  :touch
      map_char :N,  :mkdir
      map_char :p,  :cp
      map_char :m,  :mv
      map_char :r,  :rm

      map "<leftrelease> :ruby Vim::Tree.action('click')"
      map '<c-f> :ruby Vim::Tree.toggle_focus', :mode => 'n', :buffer => false
      map '<c-f> :ruby Vim::Tree.toggle_focus', :mode => 'i', :buffer => false
    end

    def update_window
      dirs = ::Dir.getwd.split('/')
      set_status(status(dirs))
      set_buffer_name(dirs.last)
    end

    def set_status(status)
      VIM.cmd "setlocal statusline=#{status}"
    end

    def set_buffer_name(name)
      VIM.cmd ":silent! file [#{name}]"
    end

    def update_tab_label
      # cmd 'set guitablabel=%{getcwd()}'
    end

    def status(dirs)
      ix = 1
      ix += 1 until ix == dirs.size - 1 || dirs[-(ix + 1)..-1].join('/').size > WIDTH - 5
      status = dirs[-ix..-1].join('/')
      status = "../#{status}" if ix < dirs.size
      status = status.gsub('//', '/')
    end

    def map_char(char, target = char, options = {})
      map_key :"Char-#{char.to_s.ord}", target, options
    end

    def map_key(key, target = key, options = {})
      map "<#{key}> :ruby Vim::Tree.action('#{target.to_s.downcase}')", options
    end

    def map(command, options = {})
      options[:mode] ||= :nnore
      options[:buffer] = true unless options.key?(:buffer)
      cmd "#{options[:mode]}map <silent> #{'<buffer>' if options[:buffer]} #{'<esc>' if options[:mode] == 'i'}#{command}<CR>"
    end
  end
end
