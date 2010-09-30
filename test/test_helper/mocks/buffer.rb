module Mocks
  class Buffer < Array
    attr_accessor :line_number
  
    def initialize(line_number = 1)
      @line_number = line_number
    end
    
    def display(lines)
      clear
      lines.each_with_index { |line, ix| append(ix, line) }
      delete(length)
    end
    
    def append(ix, line)
      self << line
    end
    
    def delete(ix)
    end
  end
end