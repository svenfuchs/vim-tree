function! s:FsTreeStart()
  ruby << RUBY
    $: << File.expand_path('~/.vim/plugin/fs_tree/lib')
    require 'fs_tree'
    $fs_window = FsTree.run(Dir.pwd)
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
  ruby $fs_window.sync(path) if $fs_window
endfunction

function! s:FsTreeReloadLib()
  ruby << RUBY
    path = File.expand_path('~/.vim/plugin/fs_tree/lib')
    Dir["#{path}/**/*.rb"].each { |path| load(path) }
RUBY
endfunction

command! FsTree :call <SID>FsTreeStart()
command! FsTreeReloadLib :call <SID>FsTreeReloadLib()


