require 'core_ext/vim/vim'
require 'core_ext/vim/buffer'
require 'core_ext/vim/window'

module Vim
  module Tree
    module Window
      def set_status(status)
        VIM.cmd "setlocal statusline=#{status}"
      end

      def set_buffer_name(name)
        VIM.cmd ":silent! file [#{name}]"
      end

      def tree?
        singleton_class.included_modules.include?(Vim::Tree)
      end
    end
  end

  class Window
    include Vim::Tree::Window
  end
end
