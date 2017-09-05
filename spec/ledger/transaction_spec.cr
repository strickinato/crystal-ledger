require "spec"
require "../../src/ledger/transaction"

describe Ledger::Transaction do
  it "has all the necessary properties" do
    transaction = Ledger::Transaction.new(
      date: Time.new(2015, 10, 10),
      cleared: true,
      description: "Hey - here's a transaction",
      tags: ["hello", "bybye"],
      comments: ["This is a comment"],
      entries: [
        Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil),
        Ledger::Transaction::Entry.new(account: "Expenses:Farts", value: 321)
      ]
    )

    transaction.date.should eq Time.new(2015, 10, 10)
    transaction.cleared?.should eq true
    transaction.description.should eq "Hey - here's a transaction"
    transaction.tags.should eq ["hello", "bybye"]
    transaction.comments.should eq ["This is a comment"]
    transaction.entries.should eq [ Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil),
                                    Ledger::Transaction::Entry.new(account: "Expenses:Farts", value: 321)
                                  ]
  end

  describe "#to_string" do
    it "handles a cleared transaction" do
      transaction = Ledger::Transaction.new(
        date: Time.new(2015, 10, 10),
        cleared: true,
        description: "Hey - here's a transaction",
        tags: ["hello", "bybye"],
        comments: ["This is a comment"],
        entries: [
          Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil),
          Ledger::Transaction::Entry.new(account: "Expenses:Farts", value: 321)
        ]
      )

      expected = <<-EXPECTED
      2015/10/10 * Hey - here's a transaction
          ;This is a comment
          Expenses:Farts                                       $3.21
          Asset:Checking
      EXPECTED

      transaction.to_string.should eq expected
    end

    it "handles many entries" do
      transaction = Ledger::Transaction.new(
        date: Time.new(2015, 10, 10),
        cleared: false,
        description: "Hey - here's a transaction",
        tags: ["hello", "bybye"],
        comments: [] of String,
        entries: [
          Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil),
          Ledger::Transaction::Entry.new(account: "Expenses:Farts", value: 321),
          Ledger::Transaction::Entry.new(account: "Expenses:Hello", value: -3912)
        ]
      )

      expected = <<-EXPECTED
      2015/10/10 Hey - here's a transaction
          Expenses:Farts                                       $3.21
          Expenses:Hello                                     $-39.12
          Asset:Checking
      EXPECTED

      transaction.to_string.should eq expected
    end
  end

  describe "validates the data" do
    context "given NO entries" do
      it "it should tell us we need entries" do
        expect_raises(Ledger::Transaction::InvalidEntriesException, "There needs to be at least two entries") do
          Ledger::Transaction.new(
            date: Time.new(2015, 10, 10),
            cleared: true,
            description: "Hey - here's a transaction",
            tags: ["hello", "bybye"],
            comments: ["This is a comment"],
            entries: [] of Ledger::Transaction::Entry
          )
        end
      end
    end

    context "given ONE entry" do
      it "it should tell us we need entries" do
        expect_raises(Ledger::Transaction::InvalidEntriesException, "There needs to be at least two entries") do
          Ledger::Transaction.new(
            date: Time.new(2015, 10, 10),
            cleared: true,
            description: "Hey - here's a transaction",
            tags: ["hello", "bybye"],
            comments: ["This is a comment"],
            entries: [ Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil) ],
          )
        end
      end
    end

    context "given multiple bank entries" do
      it "it should tell us we can't have that many blanks" do
        expect_raises(Ledger::Transaction::InvalidEntriesException, "Can't have multiple blank entries") do
          Ledger::Transaction.new(
            date: Time.new(2015, 10, 10),
            cleared: true,
            description: "Hey - here's a transaction",
            tags: ["hello", "bybye"],
            comments: ["This is a comment"],
            entries: [
              Ledger::Transaction::Entry.new(account: "Asset:Checking", value: nil),
              Ledger::Transaction::Entry.new(account: "Expenses:Other", value: nil)
            ],
          )
        end
      end
    end

    context "given all explicit values" do
      it "it should tell us if numbers don't add up" do
        expect_raises(Ledger::Transaction::InvalidEntriesException, "Debits and Credits don't balance to 0") do
          Ledger::Transaction.new(
            date: Time.new(2015, 10, 10),
            cleared: true,
            description: "Hey - here's a transaction",
            tags: ["hello", "bybye"],
            comments: ["This is a comment"],
            entries: [
              Ledger::Transaction::Entry.new(account: "Asset:Checking", value: 132),
              Ledger::Transaction::Entry.new(account: "Expenses:Other", value: -100),
              Ledger::Transaction::Entry.new(account: "Other", value: -100)
            ],
          )
        end
      end

      it "shouldn't complain if they do add up" do
        Ledger::Transaction.new(
          date: Time.new(2015, 10, 10),
          cleared: true,
          description: "Hey - here's a transaction",
          tags: ["hello", "bybye"],
          comments: ["This is a comment"],
          entries: [
            Ledger::Transaction::Entry.new(account: "Asset:Checking", value: 132),
            Ledger::Transaction::Entry.new(account: "Expenses:Other", value: -100),
            Ledger::Transaction::Entry.new(account: "Other", value: -32)
          ],
        )
      end
    end
  end
end
