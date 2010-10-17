module Vim
  class Window
    def tree?
      singleton_class.included_modules.include?(Vim::Tree)
    end
  end
end
