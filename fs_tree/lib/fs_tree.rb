require 'forwardable'

module FsTree
  autoload :Directory, 'fs_tree/directory'
  autoload :File,      'fs_tree/file'
  autoload :List,      'fs_tree/list'
  autoload :Node,      'fs_tree/node'
  autoload :Vim,       'fs_tree/vim'
  autoload :Window,    'fs_tree/window'

  class << self
    def run(window, path)
      Window.new(Vim.new(window), path)
    end
  end
end

class String
  def starts_with?(other)
    self[0, other.length] == other
  end

  unless RUBY_VERSION >= '1.9'
    def ord
      self[0]
    end
  end
end

module VIM
  def self.filename_escape(s)
    # Escape slashes, open square braces, spaces, sharps, and double quotes.
    s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
  end
end
