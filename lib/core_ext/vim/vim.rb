module Vim
  module Helpers
    def cwd(path)
      cmd "cd #{path.to_s}"
    end

    def block_events(&block)
      with_setting(:eventignore, 'all', &block)
    end

    def with_setting(name, value, &block)
      old = set(name, value)
      yield
      set(name, old)
    end

    def set(name, value)
      eval("&#{name}").tap { cmd "set #{name}=#{value}" }
    end

    def cmd(s)
      ::VIM.command(s)
    end

    def eval(s)
      ::VIM.evaluate(s)
    end

    # Escape slashes, open square braces, spaces, sharps, and double quotes.
    def escape(string)
      string.to_s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
    end
  end

  extend Helpers
  include Helpers
end
