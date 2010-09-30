unless RUBY_VERSION >= '1.9'
  class String
    def ord
      self[0]
    end
  end
end