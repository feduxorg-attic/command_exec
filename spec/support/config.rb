RSpec.configure do |c|
  c.include CommandExec::SpecHelper
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run_including :focus => true
  c.run_all_when_everything_filtered = true
end

