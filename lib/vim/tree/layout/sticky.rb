require 'core_ext/ruby/kernel/singleton_class'
require 'vim/tree/window'

module Vim
  module Tree
    module Layout
      module Sticky
        class << self
          include Vim

          def included(base)
            position!
            cmd 'au WinLeave * :ruby Vim::Window.previous = $curwin'
            # cmd 'au WinEnter * :ruby Vim::Layout::Sticky.position!'
            # %w(H J K L).each { |key| map_wincmd(key) }
          end

          def position!
            window = Vim::Window.detect { |window| window.sticky? }
            window.position! if window
          end

          def map_wincmd(key)
            cmd "nmap <C-w>#{key} :exe 'wincmd #{key}'<CR>:ruby Vim::Layout::Sticky.position!<CR>"
          end
        end

        COMMANDS = {
          :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
          :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
        }
        WIDTH = 30

        def position!
          focussed do
            cmd 'wincmd H'
            cmd "vertical resize #{WIDTH}"
          end
        end

        def split(path)
          open(path, :split)
        end

        def vsplit(path)
          open(path, :vsplit)
        end

        def open(path, mode = :normal)
          if mode == :normal && window = Vim::Window.find(path)
            window.focus
          elsif mode == :normal
            open(path, :split)
          else
            Vim::Window.previous! if tree?
            cmd "#{COMMANDS[:file][mode]} #{escape(path)}"
            # position!
          end
        end
      end
    end
  end

  class Window
    def sticky?
      singleton_class.included_modules.include?(Vim::Tree::Layout::Sticky)
    end
  end
end
