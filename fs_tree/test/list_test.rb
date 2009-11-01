require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ListTest < Test::Unit::TestCase
  def setup
    @list = list
  end

  test "contains the root directories flattened nodes" do
    assert_equal %w(a aa a.x), @list.map { |node| node.name }
  end

  test "open inserts the flattened nodes list of the opened node" do
    @list.open(1)
    assert_equal %w(a aa aa.x aa.y a.x), @list.map { |node| node.name }
  end

  test "close removes the flattened nodes list of the closed node" do
    @list.open(1)
    @list.close(1)
    assert_equal %w(a aa a.x), @list.map { |node| node.name }
  end

  test "expand sets the root path one level up" do
    @list.expand
    assert_equal %w(fixtures a aa a.x b), @list.map { |node| node.name }
  end

  test "expand maintains the open directories" do
    @list.open(1)
    @list.expand
    assert_equal %w(fixtures a aa aa.x aa.y a.x b), @list.map { |node| node.name }
  end

  test "collapse sets the rot path to the given child's path" do
    @list.collapse(1)
    assert_equal %w(aa aa.x aa.y), @list.map { |node| node.name }
  end

  test "collapse maintains the open directories" do
    @list.open(1)
    @list.expand
    @list.collapse(1)
    assert_equal %w(a aa aa.x aa.y a.x), @list.map { |node| node.name }
  end

  test "local? is true when the given path is part of the root directory" do
    assert @list.local?(root + '/aa')
  end

  test "local? is false when the given path is not part of the root directory" do
    assert !@list.local?(File.expand_path(root + '/../'))
  end

  test "local? is false when the given path does not exist" do
    assert !@list.local?(root + '/x')
  end

  test "find finds a local file and opens all enclosing closed directories" do
    @list.find(root + '/aa/aa.x')
    assert_equal %w(a aa aa.x aa.y a.x), @list.map { |node| node.name }
  end
end
