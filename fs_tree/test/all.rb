Dir[File.dirname(__FILE__) + '/**/*_test.rb'].each do |path|
  require path
end
