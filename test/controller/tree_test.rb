require File.expand_path('../../test_helper', __FILE__)

class ControllerTreeTest < Test::Unit::TestCase
  attr_reader :buffer, :window, :controller, :model, :view

  def setup
    super
    @buffer = Mocks::Buffer.new
    @window = Mocks::Window.new(buffer)
    @controller = Controller::Tree.new(window, root)
  end

  test "ensure the root directory is open, everything else is closed and the cursor on in the first line" do
    controller.render
    assert_equal '▾ root  ▸ bar  ▸ foo', buffer.join
    assert_equal 0, controller.current_line
  end

  test 'move_to moves the cursor to the given line' do
    controller.move_to(4)
    assert_equal 4, controller.current_line
  end

  test 'move_down moves the cursor down by one line' do
    controller.move_to(0)
    3.times { controller.move_down }
    assert_equal 3, controller.current_line
  end

  test 'move_up moves the cursor up by one line' do
    controller.move_to(4)
    3.times { controller.move_up }
    assert_equal 1, controller.current_line
  end

  test 'left closes the current directory if the current directory is open' do
    controller.left
    assert_equal '▸ root', buffer.join
  end

  test 'click opens a directory if it is closed' do
    controller.move_to(2)
    controller.click
    assert_equal '▾ root  ▸ bar  ▾ foo    ▸ foo', buffer.join
  end

  test 'click closes a directory if it is open' do
    controller.move_to(0)
    controller.click
    assert_equal '▸ root', buffer.join
  end

  test "left closes the current directory's parent if the current directory is closed" do
    controller.move_to(2)
    controller.left
    assert_equal '▸ root', buffer.join
    assert_equal 0, controller.current_line
  end

  test 'right opens the current directory if it is closed and moves the cursor down by one line' do
    controller.left
    assert_equal '▸ root', buffer.join
    controller.right
    assert_equal '▾ root  ▸ bar  ▸ foo', buffer.join
    assert_equal 1, controller.current_line
  end

  # TODO split, vsplit

  test 'move_in makes the current directory the root directory' do
    controller.move_to(2)
    controller.move_in
    assert_equal '▾ foo  ▸ foo', buffer.join
  end

  test "move_out makes the current root's parent directory the root directory" do
    controller.move_out
    assert_equal '▾ vim_tree-test  ▸ root', buffer.join
  end
end
