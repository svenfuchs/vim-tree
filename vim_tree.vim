function! s:VimTree(path)
  ruby << rb
    unless defined?(VimTree)
      $:.unshift File.expand_path('~/Development/projects/vim_tree/lib')
      require 'vim_tree'
    end

    if VimTree.current
      VimTree.current.focus()
    else
      path = Vim.evaluate('a:path')
      VimTree.run(path.empty? ? Dir.pwd : path)
    end
rb
endfunction

function! VimTreeAction(action)
  ruby << rb
    action = Vim.evaluate("a:action")
    VimTree.current.action(action) if VimTree.current
rb
endfunction

function! VimTreeSync(path)
  ruby << rb
    path = VIM.evaluate("a:path")
    VimTree.current.sync_to(path) if VimTree.current && !VimTree.current.focussed?
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
command! VimTreeStatus :call <SID>VimTreeStatus()

exe "map  <c-f> <esc>:VimTree<CR>"
exe "imap <c-f> <esc>:VimTree<CR>"
