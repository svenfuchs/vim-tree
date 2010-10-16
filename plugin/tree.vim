function! s:VimTree(path)
  ruby <<
    unless defined?(VimTree)
      path = ::VIM.evaluate('&runtimepath').split(',').detect { |p| p.include?('vim-tree') }
      $:.unshift("#{path}/lib")
      require 'vim/tree'
    end

    if Vim::Tree.window
      Vim::Tree.window.focus()
    else
      paths = [::VIM.evaluate('a:path'), $curwin.buffer.name, Dir.pwd].compact
      paths.reject! { |path| path.empty? }
      path = File.expand_path(paths.first)
      Vim::Tree.run(path) if File.directory?(path)
    end
.
endfunction

function! VimTreeAction(action)
  ruby <<
    action = ::VIM.evaluate("a:action")
    ::Vim::Tree.window.action(action) if Vim::Tree.window
.
endfunction

function! VimTreeSync(path)
  ruby <<
    path = ::VIM.evaluate("a:path")
    ::Vim::Tree.window.sync_to(path) if Vim::Tree.window && !Vim::Tree.window.focussed?
.
endfunction

function! s:VimTreeFocus()
  ruby <<
    ::Vim::Tree.window.toggle_focus
.
endfunction

function! s:VimTreePosition()
  ruby ::Vim::Tree.window.position!
endfunction

function! s:VimTreeReload()
  ruby <<
    lib = File.expand_path('~/Development/projects/vim_tree/lib')
    Dir["#{lib}/**/*.rb"].each { |path| load(path) }
.
endfunction

command! -nargs=? -complete=dir VimTree :call <SID>VimTree("<args>")
command! VimTreeFocus :call <SID>VimTreeFocus()
command! VimTreePosition :call <SID>VimTreePosition()
command! VimTreeReload :call <SID>VimTreeReload()

" au BufAdd * :call s:VimTreePosition()
au BufWritePost * :call VimTreeAction('refresh')
au FocusLost * :silent! wa

map  <c-f> <esc>:VimTreeFocus<CR>
imap <c-f> <esc>:VimTreeFocus<CR>

" this should keep the vim tree window sticking to the left. works most of the
" time but not always, no idea why.
map <C-w>K :exe "wincmd K"<CR>:VimTreePosition<CR>
map <C-w>J :exe "wincmd J"<CR>:VimTreePosition<CR>
map <C-w>H :exe "wincmd H"<CR>:VimTreePosition<CR>
map <C-w>L :exe "wincmd L"<CR>:VimTreePosition<CR>

