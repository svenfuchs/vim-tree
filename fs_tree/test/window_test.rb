require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class WindowTest < Test::Unit::TestCase
  test "cwd_root changes the current working directory to the current root" do
    window.cwd_root
    assert_equal 'a', File.basename(vim.working_directory)
  end

  test "cwd changes the current working directory to the current path" do
    vim.move_to(1)
    window.cwd
    assert_equal 'aa', File.basename(vim.working_directory)
  end

  test "expand makes the root's parent directory the root directory" do
    window.expand
    assert_match /fixtures/, vim.lines.first
    assert_equal 1, vim.line
  end

  test "collapse makes the current directory the root directory" do
    vim.move_to(1)
    window.collapse
    assert_match /aa/, vim.lines.first
    assert_equal 0, vim.line
  end

  test "click on a closed directory opens the directory" do
    vim.move_to(1)
    window.click
    assert window.send(:current).open?
    assert_equal 'aa', window.send(:current).name
  end

  test "click on an open directory closes the directory" do
    window.click
    assert !window.send(:current).open?
    assert_equal 'a', window.send(:current).name
  end

  test "click on a file opens the file" do
    vim.move_to(2)
    window.click
    assert_equal 'a.x', File.basename(vim.open_path)
  end

  test "left closes an open directory" do
    window.left
    assert_equal 1, vim.lines.size
    assert_equal 0, vim.line
  end

  test "left closes the parent directory of an open directory" do
    vim.move_to(1)
    window.left
    assert_equal 1, vim.lines.size
    assert_equal 0, vim.line
  end

  test "left closes the parent directory of a file" do
    vim.move_to(2)
    window.left
    assert_equal 1, vim.lines.size
    assert_equal 0, vim.line
  end

  test "right opens a closed directory and moves into it" do
    vim.move_to(1)
    window.right
    assert_equal 5, vim.lines.size
    assert_equal 2, vim.line
  end

  test "right opens a file" do
    vim.move_to(2)
    window.right
    assert_equal 'a.x', File.basename(vim.open_path)
  end

  test "page_up on any other sibling moves to the first sibling" do
    vim.move_to(1)
    window.click
    vim.move_to(3)
    window.page_up
    assert_equal 2, vim.line
  end

  test "page_up on the first sibling moves to the parent directory's first sibling" do
    vim.move_to(1)
    window.click
    vim.move_to(2)
    window.page_up
    assert_equal 1, vim.line
  end

  test "page_down on any other sibling moves to the last sibling" do
    vim.move_to(1)
    window.click
    vim.move_to(2)
    window.page_down
    assert_equal 3, vim.line
  end

  test "page_down on the first sibling moves to the parent directory's last sibling" do
    vim.move_to(1)
    window.click
    vim.move_to(3)
    window.page_down
    assert_equal 4, vim.line
  end
end
