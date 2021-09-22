require "rails_helper"

# Tests our monkey-patching of Wice::Spreadsheet to add a byte order mark.
describe Wice::Spreadsheet do
  it "adds byte order mark to CSV output" do
    spreadsheet = described_class.new("foo", ",")
    spreadsheet << ["bar", "baz"]
    csv = spreadsheet.tempfile.tap(&:rewind).read
    expect(csv).to eq("\xEF\xBB\xBFbar,baz\n")
  end
end
