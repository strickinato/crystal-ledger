require "spec"
require "../../src/ledger/importer"

describe Ledger::Importer do
  csv = <<-CSV
Date,aaron,something
2017-08-09,2,3
CSV

  it "instantiates" do
    Ledger::Importer.new(csv: csv).is_a?(Ledger::Importer)
  end
end
