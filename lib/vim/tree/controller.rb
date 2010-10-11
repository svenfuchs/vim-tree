module Vim
  module Tree
    module Controller
      attr_reader :dir, :view

      def init(dir)
        @dir  = Model::Dir.new(dir, nil, :open)
        @view = View::Tree.new(self.dir)
      end

      def action(action)
        Vim::Tree.store_last_window
        send(action)
      end

      def sync_to(path)
        if Vim::Tree.valid? && ix = dir.index(path)
          maintain_window do
            move_to(ix)
            render
          end
        end
      end

      def refresh
        focussed do
          dir.reset(:maintain_status => true)
          render
        end
      end

      def position!
        focussed do
          cmd "#{number} wincmd H"
          cmd "vertical resize #{Vim::Tree::WIDTH}"
          move_to(line_number)
        end
      end

      def cwd_root
        cwd(dir)
      end

      def cwd(path = line)
        Vim.cwd(path) if path.directory?
        update_status
      end

      def move_up
        move_to(line_number - 1)
      end

      def move_down
        move_to(line_number + 1)
      end

      def click
        if line.directory?
          line.toggle
        else
          open(line)
        end
        render
      end

      def split
        super(line) if line.file?
        render
      end

      def vsplit
        super(line) if line.file?
        render
      end

      def left
        move_to(dir.index(line.parent)) unless line.directory? && line.open?
        line.close
        render
      end

      def right
        if line.directory?
          line.open
          move_down
        else
          open(line)
        end
        render
      end

      def shift_left
        move_to(dir.index(line.parent)) unless line.directory? && line.open?
        line.close(:recursive => true)
        render
      end

      def shift_right
        if line.directory?
          line.open(:recursive => true)
          render
        else
          open(line)
          focus
        end
      end

      def page_up
        target = line.first_sibling? ? line.parent && line.parent.first_sibling : line.first_sibling
        move_to(dir.index(target))
      end

      def page_down
        target = line.last_sibling? ? line.parent && line.parent.last_sibling : line.last_sibling
        move_to(dir.index(target))
      end

      def move_out
        maintain_line do
          dir.move_out
          render
        end
      end

      def move_in
        dir.move_in(line)
        move_to(0)
        render
      end

      def move_to(line)
        self.cursor = [line.to_i + 1, 0] if line
      end

      def line
        dir[line_number]
      end

      def line_number
        buffer.line_number - 1
      end

      def render
        unlocked do
          buffer.display(view.render)
        end
      end
    end
  end
end
