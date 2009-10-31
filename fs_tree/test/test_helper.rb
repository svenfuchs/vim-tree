$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'mocha'
require 'fs_tree'

Test::Unit::TestCase.class_eval do
  def teardown
    window = nil
  end

  def root
    @root ||= File.expand_path(File.dirname(__FILE__) + '/fixtures/a')
  end

  def window
    @window ||= FsTree::Window.new(VimMock.new, root)
  end

  def vim
    window.vim
  end

  def list
    FsTree::List.new(root)
  end

  def directory
    FsTree::Node.build(root)
  end

  def file
    FsTree::Node.build(root + '/a.z')
  end

  def self.test(name, &block)
    define_method :"test_#{name}", &block
  end
end

class VimMock
  extend Forwardable

  COMMANDS = {
    :file => { :normal => 'e', :split => 'sp', :vsplit => 'vs' },
    :buff => { :normal => 'b', :split => 'sb', :vsplit => 'vert sb' }
  }

  attr_reader :working_directory, :lines, :open_path, :open_mode

  def initialize
    @line = 1
  end

  def cwd(path)
    @working_directory = path
  end

  def open(path, mode = :normal)
    @open_path = path
    @open_mode = mode
  end

  def split(path)
    open(path, :split)
  end

  def vsplit(path)
    open(path, :vsplit)
  end

  def line
    @line - 1
  end

  def move_up(distance = 1)
    move_to(line - distance)
  end

  def move_down(distance = 1)
    move_to(line + distance)
  end

  def move_to(line)
    @line = line + 1
  end

  def draw(lines)
    @lines = lines
  end
end

