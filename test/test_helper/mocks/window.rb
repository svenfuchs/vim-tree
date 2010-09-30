module Mocks
  class Window < Array
    attr_accessor :buffer, :cursor
  
    def initialize(buffer)
      @buffer = buffer
      @cursor = [1, 1]
    end
    
    def cursor=(point)
      @cursor = point
      buffer.line_number = point.first
    end
    
    def focussed
      yield
    end
    alias :unlocked :focussed
  end
end