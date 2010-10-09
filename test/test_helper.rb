$:.unshift File.expand_path('../../lib', __FILE__)
$:.unshift File.expand_path('..', __FILE__)

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'test_declarative'
require 'pathname'
require 'fileutils'
require 'vim/tree'

class Test::Unit::TestCase
  autoload :Mocks, 'test_helper/mocks'

  include Vim::Tree

  attr_reader :root

  def setup
    @root = Pathname.new('/tmp/vim-tree-test/root')
    setup_test_directory
  end

  def teardown
    root.rmtree
  end

  def setup_test_directory
    root.mkpath
    files = %w(
      bar/bar.rb
      bar/foo.rb
      foo/foo/foo.rb
    )
    files.each do |file|
      root.join(file).dirname.mkpath
      FileUtils.touch(root.join(file))
    end
  end
end
