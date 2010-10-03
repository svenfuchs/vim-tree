require 'vim/buffer'
require 'vim/window'

module Vim
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
    old = eval("&#{name}")
    cmd "set #{name}=#{value}"
    old
  end

  def cmd(s)
    Vim.command(s)
  end

  def eval(s)
    Vim.evaluate(s)
  end

  def map_char(char, target = char, options = {})
    map_key :"Char-#{char.to_s.ord}", target, options
  end

  def map_key(key, target = key, options = {})
    map "<#{key}> :call VimTreeAction('#{target.to_s.downcase}')", options
  end

  def map(command, options = {})
    options[:buffer] = true unless options.key?(:buffer)
    cmd "nnoremap <silent> #{'<buffer>' if options[:buffer]} #{command}<CR>"
  end

  # Escape slashes, open square braces, spaces, sharps, and double quotes.
  def escape(string)
    string.to_s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"]/, '\\\\\0')
  end

  extend self
end
