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
    @window ||= begin
      window = Vim::Window.new
      window.extend(FsTree::Window)
      window.init('', VimMock.new)
      window
    end
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
    @line = 0
    @lines = []
  end

  def cwd(path)
    @working_directory = path
  end

  def split(path)
    open(path, :split)
  end

  def vsplit(path)
    open(path, :vsplit)
  end

  def open(path, mode = :normal)
    @open_path = path
    @open_mode = mode
  end

  def line
    @line
  end

  def move_to(line)
    @line = line
  end

  def write(lines)
    @lines = lines
  end

  def local
    yield
  end

  def block(event, &block)
    yield
  end

  def blocked?(event)
    false
  end

  def exe(command)
  end

  def eval(expression)
  end
end

