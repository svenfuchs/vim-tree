function! s:FsTreeStart()
  ruby << RUBY
    $: << File.expand_path('~/.vim/plugin/fs_tree/lib')
    require 'fs_tree'
    $fs_tree = FsTree.run($curwin, Dir.pwd)
RUBY
endfunction

function! FsTreeAction(action)
  ruby action = Vim.evaluate("a:action")
  ruby $fs_tree.action(action)
endfunction

function! s:FsTreeReloadLib()
  ruby << RUBY
    path = File.expand_path('~/.vim/plugin/fs_tree/lib')
    Dir["#{path}/**/*.rb"].each { |path| load(path) }
RUBY
endfunction

command! FsTree :call <SID>FsTreeStart()
command! FsTreeReloadLib :call <SID>FsTreeReloadLib()

