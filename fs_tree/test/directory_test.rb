require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'fs_tree/node'

class DirectoryTest < Test::Unit::TestCase
  def setup
    @directory = directory
    @directory.children.first.open
  end

  test "lazy loads child nodes" do
    assert !@directory.children.empty?
  end

  test "child entries level is current level + 1" do
    assert_equal @directory.level + 1, @directory.children.first.level
  end

  test "map iterates over the children collection" do
    assert_equal %w(aa a.x), @directory.map { |node| node.name }
  end

  test "flatten returns a flattened list of all open nested children" do
    assert_equal %w(a aa aa.x aa.y a.x), @directory.flatten.map { |node| node.name }
  end

  test "find finds a local file and opens all enclosing closed directories" do
    node = @directory.find(root + '/aa/aa.x')
    assert_equal root + '/aa/aa.x', node.path
    assert_equal %w(a aa aa.x aa.y a.x), @directory.flatten.map { |node| node.name }
  end

  test "open(:recursive => true) opens all children recursively" do
    @directory.close(:recursive => true)
    @directory.open(:recursive => true)
    assert_equal %w(a aa aa.x aa.y a.x), @directory.flatten.map { |node| node.name }
    assert @directory.open?
    assert @directory.find(root + '/aa').open?
  end

  test "close(:recursive => true) closes all children recursively" do
    @directory.open(:recursive => true)
    @directory.close(:recursive => true)

    assert !@directory.open?
    assert !@directory.find(root + '/aa').open?
  end
end
