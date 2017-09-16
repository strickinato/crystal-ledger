require "spec"
require "../../src/ledger"

describe Ledger::Importer::Chase::SapphireReserve do
  csv = <<-CSV
Type,Trans Date,Post Date,Description,Amount
Sale,09/09/2017,09/11/2017,SEX PALACE GOOD T*MES,-6.65
CSV

  it "instantiates" do
    Ledger::Importer::Chase::SapphireReserve.new(csv: csv).is_a?(Ledger::Importer::Chase::SapphireReserve)
  end

  transaction = Ledger::Importer::Chase::SapphireReserve.new(csv: csv).transactions.first
  entries = transaction.entries

  it "sets the date" do
    transaction.date.should eq Time.new(2017, 9, 9)
  end

  it "is always cleared" do
    transaction.cleared?.should eq true
  end

  it "records the name of the vendor as the description" do
    transaction.description.should eq "SEX PALACE GOOD T*MES"
  end

  it "puts it in the correct account" do
    entries.first.account.should eq "Liabilities:CreditCard:Chase:SapphireReserve"
  end

  it "records the right value" do
    entries.first.value.should eq -665
  end

  it "creates a too be filled in category section" do
    entries.last.account.should eq "???"
    entries.last.value.should eq nil
  end
end
