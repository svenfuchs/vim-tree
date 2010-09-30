module VimTree
  module Controller
    class Tree
      attr_reader :tree, :window, :view

      def initialize(window, root)
        @window = window
        @tree   = Model::Dir.new(root, nil, :open)
        @view   = View::Tree.new(tree)
      end

      def action(action)
        # if validate && respond_to?(action)
          Vim.last_window = Vim.previous
          send(action)
        # end
      end

      def quit
        Vim.quit_vim_tree
      end

      def sync_to(path)
        if validate && ix = list.find(path)
          vim.maintain_window do
            move_to(ix)
            render
          end
        end
      end

      def refresh
        render
      end

      def cwd_root
        Vim.cwd(tree)
      end

      def cwd
        Vim.cwd(current) if current.directory?
      end

      def move_up
        move_to(current_line - 1)
      end

      def move_down
        move_to(current_line + 1)
      end

      def click
        if current.directory?
          current.toggle
          render
        else
          Vim.open(current)
        end
      end

      def split
        Vim.split(current) if current.file?
      end

      def vsplit
        Vim.vsplit(current) if current.file?
      end

      def left
        move_to(tree.index(current.parent)) unless current.directory? && current.open?
        current.close
        render
      end

      def right
        if current.directory?
          current.open
          move_down
          render
        else
          Vim.open(current)
        end
      end

     def shift_left
       move_to(tree.index(current.parent)) unless current.directory? && current.open?
       current.close(:recursive => true)
       render
     end

     def shift_right
       current.open(:recursive => true)
       render
     end

     def move_out
       maintain_line do
         tree.move_out
         render
       end
     end

      def move_in
        tree.move_in(current)
        move_to(0)
        render
      end

      def move_to(line)
        window.cursor = [line.to_i + 1, window.cursor[1]] if line
      end

      def current
        tree[current_line]
      end

      def current_line
        window.buffer.line_number - 1
      end

      def render
        window.focussed do
          window.unlocked do
            window.buffer.display(view.render)
          end
        end
      end

      def maintain_line(&block)
        current = self.current
        yield
        move_to(tree.index(current)) if current
      end
    end
  end
end
