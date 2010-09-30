function! s:VimTree(path)
  ruby << rb
    if $vim_tree
      $vim_tree.focus()
    else
      $:.unshift File.expand_path('~/Development/projects/vim_tree/lib')
      require 'vim_tree'
      path = Vim.evaluate('a:path')
      $vim_tree = VimTree.run(path.empty? ? Dir.pwd : path)
    end
rb
endfunction

function! VimTreeAction(action)
  ruby << rb
    action = Vim.evaluate("a:action")
    $vim_tree.action(action) if $vim_tree
rb
endfunction

function! FsTreeSync(path)
  ruby << rb
    path = VIM.evaluate("a:path")
    $vim_tree.sync_to(path) if $vim_tree && $vim_tree != $curwin
rb
endfunction

function! s:VimTreeReload()
  ruby << rb
    lib = File.expand_path('~/Development/projects/vim_tree/lib')
    Dir["#{lib}/**/*.rb"].each { |path| load(path) }
rb
endfunction

command! -nargs=? -complete=dir VimTree :call <SID>VimTree("<args>")
command! VimTreeReload :call <SID>VimTreeReload()

exe "map  <c-f> <esc>:VimTree<CR>"
exe "imap <c-f> <esc>:VimTree<CR>"