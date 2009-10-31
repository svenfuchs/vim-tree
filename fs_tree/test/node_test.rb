require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class NodeTest < Test::Unit::TestCase
  test "build returns a Directory instance for a directory path" do
    assert directory.directory?
  end

  test "build returns a File instance for a file path" do
    assert file.file?
  end

  test "name returns a directorys basename" do
    assert_equal 'a', directory.name
  end

  test "name returns a files basename" do
    assert_equal 'a.z', file.name
  end
end
