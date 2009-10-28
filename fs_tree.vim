function! s:FsTreeStart()
  ruby << RUBY
    $: << File.expand_path(File.dirname(__FILE__)) + '/.vim/plugin/fs_tree/lib'
    require 'fs_tree'

    window = FsTree::Window.new($curwin, $curbuf)
    list = FsTree::List.new('/Users/sven/Development/lab/vim')
    $fs_tree = FsTree::Pane.new(window, list)
    $fs_tree.redraw
RUBY
endfunction

function! FsTreeAction(action)
  ruby action = Vim.evaluate("a:action")
  ruby $fs_tree.action(action)
endfunction

function! s:FsTreeReloadLib()
  ruby << RUBY
    path = File.expand_path(File.dirname(__FILE__)) + '/.vim/plugin/fs_tree/lib'
    Dir["#{path}/**/*.rb"].each { |path| load(path) }
RUBY
endfunction

command! FsTree :call <SID>FsTreeStart()
command! FsTreeReloadLib :call <SID>FsTreeReloadLib()

