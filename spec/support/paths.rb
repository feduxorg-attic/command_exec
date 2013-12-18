RSpec.configure do |c|
  c.before(:all) do
    def examples_directory
      File.expand_path('../../examples', __FILE__)
    end
  end
end
