# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'vim_tree/version'

Gem::Specification.new do |s|
  s.name         = "vim_tree"
  s.version      = VimTree::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "http://github.com/svenfuchs/vim_tree"
  s.summary      = "[summary]"
  s.description  = "[description]"

  s.files        = `git ls-files app lib`.split("\n")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.3.6'
end
