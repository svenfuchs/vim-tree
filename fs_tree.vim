function! s:FsTreeStart(path)
  ruby << RUBY
    $: << File.expand_path('~/.vim/plugin/fs_tree/lib')
    require 'fs_tree'
    path = Vim.evaluate('a:path')
    $fs_window = FsTree.run(path.empty? ? Dir.pwd : path)
RUBY
endfunction

" function! FsTreeCleanup()
"  ruby $fs_window.validate if $fs_window
" endfunction

function! FsTreeAction(action)
  ruby action = Vim.evaluate("a:action")
  ruby $fs_window.action(action) if $fs_window
endfunction

function! FsTreeSync(path)
  ruby path = VIM.evaluate("a:path")
  ruby $fs_window.sync(path) if $fs_window && $fs_window != $curwin
endfunction

function! s:FsTreeReloadLib()
  ruby << RUBY
    path = File.expand_path('~/.vim/plugin/fs_tree/lib')
    Dir["#{path}/**/*.rb"].each { |path| load(path) }
RUBY
endfunction

command! -nargs=? -complete=dir FsTree :call <SID>FsTreeStart("<args>")
command! FsTreeReloadLib :call <SID>FsTreeReloadLib()


