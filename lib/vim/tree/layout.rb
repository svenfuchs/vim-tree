module Vim
  module Tree
    module Layout
      class << self
        include Vim

        def included(base)
          position!
          cmd 'au WinLeave * :ruby Vim::Window.previous = $curwin'
          # cmd 'au WinEnter * :ruby Vim::Tree::Layout.position!'
          # %w(H J K L).each { |key| map_wincmd(key) }
        end

        def position!
          window = Vim::Window.detect { |window| window.sticky? }
          window.position! if window
        end

        def map_wincmd(key)
          cmd "nmap <C-w>#{key} :exe 'wincmd #{key}'<CR>:ruby Vim::Tree::Layout.position!<CR>"
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
          Vim::Window.previous!
          cmd "#{COMMANDS[:file][mode]} #{escape(path)}"
          # position!
        end
      end
    end
  end
end
