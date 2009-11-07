module Vim
  class Buffer
    class << self
      include Enumerable

      def each(&block)
        i = 0
        while i < count
          yield(self[i])
          i += 1
        end
      end

      def find(path)
        detect { |buffer| buffer.name == path }
      end

      def loaded?(path)
        !!find(path)
      end
    end

    def clear
      length.times { delete(length) }
    end
  end
end
