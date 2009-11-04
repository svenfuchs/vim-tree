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
        detect { |window| window.buffer.name == path }
      end
    end

    attr_reader :vim

    def init(vim = nil)
      @vim = vim || Adapter.new(self)
    end

    def number
      @number = Window.index(self) + 1
    end

    def focussed?
      vim.focussed?(self)
    end

    def move_up(distance = 1)
      move_to(line - distance)
    end

    def move_down(distance = 1)
      move_to(line + distance)
    end

    def method_missing(method, *args, &block)
      vim.send(method, *args, &block)
    end
  end
end
