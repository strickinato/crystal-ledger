require "spec"
require "../../src/ledger/importer/chase"

describe Ledger::Importer::Chase do
  csv = <<-CSV
Type,Trans Date,Post Date,Description,Amount
Sale,09/09/2017,09/11/2017,STARBUCKS STORE 11239,-6.65
Payment,09/01/2017,09/01/2017,Payment Thank You - Web,115.13
Sale,08/16/2017,08/17/2017,CHEVRON 0090338,-37.58
Sale,08/15/2017,08/17/2017,BERKELEY BOWL WEST,-37.52
CSV

  it "instantiates" do
    Ledger::Importer::Chase.new(csv: csv).is_a?(Ledger::Importer::Chase)
  end
end
