function! s:VimTree(path)
  ruby <<
    unless defined?(VimTree)
      path = ::VIM.evaluate('&runtimepath').split(',').detect { |p| p.include?('vim-tree') }
      $:.unshift("#{path}/lib")
      require 'vim/tree'
    end

    if Vim::Tree.current
      Vim::Tree.current.focus()
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
    ::Vim::Tree.current.action(action) if Vim::Tree.current
.
endfunction

function! VimTreeSync(path)
  ruby <<
    path = ::VIM.evaluate("a:path")
    ::Vim::Tree.current.sync_to(path) if Vim::Tree.current && !Vim::Tree.current.focussed?
.
endfunction

function! s:VimTreeReload()
  ruby <<
    lib = File.expand_path('~/Development/projects/vim_tree/lib')
    Dir["#{lib}/**/*.rb"].each { |path| load(path) }
.
endfunction

command! -nargs=? -complete=dir VimTree :call <SID>VimTree("<args>")
command! VimTreeReload :call <SID>VimTreeReload()
command! VimTreeStatus :call <SID>VimTreeStatus()

exe "map  <c-f> <esc>:VimTree<CR>"
exe "imap <c-f> <esc>:VimTree<CR>"
