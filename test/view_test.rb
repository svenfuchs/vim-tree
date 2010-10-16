require File.expand_path('../test_helper', __FILE__)

class ViewTest < Test::Unit::TestCase
  attr_reader :model, :view

  def setup
    super
    @model = Model::Dir.new(root, nil, :open)
    @view  = View::Tree.new(model)
  end

  test 'render w/ a closed root' do
    model.state = :closed
    assert_equal ['▸ root'], view.render
  end

  test 'render w/ closed directories' do
    expected = ['▾ root', '  ▸ bar', '  ▸ foo']
    assert_equal expected, view.render
  end

  test 'render w/ open directories' do
    model.children[0].state = :open
    model.children[1].state  = :open

    expected = ['▾ root', '  ▾ bar', '      bar.rb', '      foo.rb', '  ▾ foo', '    ▸ foo']
    assert_equal expected, view.render
  end
end
