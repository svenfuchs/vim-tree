require File.expand_path('../../test_helper', __FILE__)

class ModelDirTest < Test::Unit::TestCase
  attr_reader :dir

  def setup
    super
    @dir = Model::Dir.new(root)
  end

  test 'children returns an array of child nodes' do
    assert_equal %w(bar foo), dir.children.map(&:basename).map(&:to_s)
  end

  test 'map iterates over children if the directory is open' do
    dir.state = :open
    assert_equal %w(bar foo), dir.map(&:basename).map(&:to_s)
  end

  test 'map does not iterate over children if the directory is closed' do
    dir.state = :closed
    assert_equal [], dir.map(&:basename).map(&:to_s)
  end

  test 'dirs returns a list of child directories' do
  end

  test 'flatten returns a flat list of nodes in open directories (1)' do
    assert_equal %w(root), dir.flatten.map(&:basename).map(&:to_s)
  end

  test 'flatten returns a flat list of nodes in open directories (2)' do
    dir.state = :open
    assert_equal %w(root bar foo), dir.flatten.map(&:basename).map(&:to_s)
  end

  test 'toggle opens a closed directory' do
    dir.state = :closed
    dir.toggle
    assert dir.open?
  end

  test 'toggle closes an open directory' do
    dir.state = :open
    dir.toggle
    assert !dir.open?
  end

  test 'move_in changes the root to the given directory' do
    dir.state = :open
    dir.move_in(dir[2])
    assert_equal %w(foo foo), dir.flatten.map(&:basename).map(&:to_s)
  end

  test "move_out changes the root to the current root's parent directory" do
    dir.state = :open
    dir.children.last.state = :open
    dir.move_out
    assert_equal %w(vim_tree-test root), dir.flatten.map(&:basename).map(&:to_s)
  end

  test "first_sibling returns a nodes first sibling" do
    assert_equal dir.children.first, dir.children.last.first_sibling
  end

  test "last_sibling returns a nodes last sibling" do
    assert_equal dir.children.last, dir.children.first.last_sibling
  end
end
