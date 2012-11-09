require 'spec_helper'

describe ErrorDetector::Contains do
  let(:data) { %w{ a b c e} }
  let(:exception) { %w{ e} }
  let(:keywords_overlap) { %w{ a } }
  let(:keywords_no_overlap) { %w{ d } }

  it "find errors" do
    detector = ErrorDetector::Contains.check(data,keywords_overlap)
    expect(detector.found_errors?).to eq(true)

  end

  it "doesn't find errors if there's no overlap" do
    detector = ErrorDetector::Contains.check(data,keywords_no_overlap)
    expect(detector.found_errors?).to eq(false)
  end
end
