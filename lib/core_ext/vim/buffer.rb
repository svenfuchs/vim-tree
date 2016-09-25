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
        detect { |buffer| buffer.name == path.to_s }
      end

      def open?(path)
        !!find(path)
      end
    end

    def clear
      length.times { delete(length) }
    end

    def display(lines)
      clear
      lines.each_with_index { |line, ix| append(ix, line) }
      delete(length)
    end
  end
end
