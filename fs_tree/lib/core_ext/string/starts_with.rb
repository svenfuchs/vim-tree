class String
  def starts_with?(other)
    self[0, other.length] == other
  end

  unless RUBY_VERSION >= '1.9'
    def ord
      self[0]
    end
  end
end

