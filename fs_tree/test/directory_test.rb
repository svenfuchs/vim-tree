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
end
