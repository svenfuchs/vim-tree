ruby <<
  module Vim
    def self.runtime_path(library)
      runtime_paths.detect { |path| path.include?(library) }
    end

    def self.runtime_paths
      ::VIM.evaluate('&runtimepath').split(',')
    end
  end

  $:.unshift("#{::Vim.runtime_path('vim-tree')}/lib").uniq!
  require 'vim/tree'
.

function! s:VimTree(path)
  ruby Vim::Tree.run(::VIM.evaluate('a:path'))
.
endfunction

command! -nargs=? -complete=dir VimTree :call <SID>VimTree('<args>')
command! VimTreeReload :ruby Vim::Tree.reload
