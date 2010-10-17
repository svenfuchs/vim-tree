ruby <<
  $:.unshift("#{::Vim.runtime_path('vim-tree')}/lib").uniq!
  require 'vim/tree'
.

function! s:VimTree(path)
  ruby Vim::Tree.run(::VIM.evaluate("a:path"))
.
endfunction

function! VimTreeAction(action)
  ruby Vim::Tree.window && Vim::Tree.window.action(::VIM.evaluate("a:action"))
.
endfunction

function! VimTreeSync(path)
  ruby Vim::Tree.window && Vim::Tree.window.sync_to(::VIM.evaluate("a:path"))
.
endfunction

command! -nargs=? -complete=dir VimTree :call <SID>VimTree("<args>")
command! VimTreeFocus  :ruby Vim::Tree.window && Vim::Tree.window.toggle_focus
command! VimTreeReload :ruby Vim::Tree.reload!

au BufWritePost * :call VimTreeAction('refresh')

map  <c-f> <esc>:VimTreeFocus<CR>
imap <c-f> <esc>:VimTreeFocus<CR>

