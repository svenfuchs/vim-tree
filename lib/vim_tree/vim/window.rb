module Vim
  class Window
    class << self
      include Enumerable

      def each(&block)
        i = 0
        while i < count
          yield(self[i])
          i += 1
        end
      end

      def index(window)
        each_with_index { |w, ix| return ix if w == window }
        nil
      end

      def find(path)
        detect { |window| window.buffer && window.buffer.name == path.to_s }
      end
      
      # def loaded?(path)
      #   !!find(path)
      # end
    end

    # def valid?
    #   !!line rescue false
    # end

    def index
      Window.index(self)
    end

    def number
      index ? index + 1 : nil
    end
    
    def focus
      Vim.focus(self)
    end
    
    def focussed(&block)
      Vim.focussed(self, &block)
    end
    
    def lock
      Vim.lock(self)
    end

    def unlocked(&block)
      Vim.unlocked(self, &block)
    end
  end
end
