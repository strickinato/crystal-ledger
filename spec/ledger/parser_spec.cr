require "spec"
require "../../src/ledger/parser"

describe Ledger::Parser do
  well_formatted_transaction = <<-LEDGER
2017/06/15 * Taco Truck
    ;here's a comment
    Assets:Checking
    Expenses:Food:Lunch Buys   -$12.00

LEDGER

  describe "#parse_transactions" do
    it "can handle 1 perfect" do
      parser = Ledger::Parser.new(well_formatted_transaction)
      parser.parse_transactions
      parser.transactions.size.should eq 1
    end

    it "can handle newlines between transactions" do
      transactions = <<-LEDGER
2017/06/15 * Taco Truck
    ;here's a comment
    Assets:Checking
    Expenses:Food:Lunch Buys   -$12.00


2017/06/15 * Taco Truck
    ;here's a comment
    Expenses:Food:Lunch Buys   -$12.00
    Assets:Checking
2017/06/15 * Taco Truck
    ;here's a comment
    Expenses:Food:Lunch Buys   -$12.00
    Assets:Checking

    ;comment
    ;comment
LEDGER

      parser = Ledger::Parser.new(transactions)
      parser.parse_transactions
      parser.transactions.size.should eq 3
    end
  end

  describe "#parse_transaction" do
    it "should handle transactions" do
      parser = Ledger::Parser.new(well_formatted_transaction)
      parsed_transaction = parser.parse_transaction
      entries = [
        Ledger::Transaction::Entry.new(account: "Assets:Checking", value: nil),
        Ledger::Transaction::Entry.new(account: "Expenses:Food:Lunch Buys", value: -1200),
      ]
      expected_transaction = Ledger::Transaction.new(
        date: Time.new(2017, 6, 15),
        cleared: true,
        description: "Taco Truck",
        comments: [ "here's a comment" ],
        entries: entries,
        tags: [] of String,
      )

      parsed_transaction.should eq expected_transaction
    end
  end

  describe "#parse_date" do
    it "can pull out the time of a well formatted transaction" do
      date_string = "2017/06/15 rest of the stuff"
      parser = Ledger::Parser.new(date_string)
      parsed_transaction = parser.parse_time
      parsed_transaction.should eq Time.new(2017, 6, 15)
      parser.buffer.offset.should eq 11
    end

    it "fails on a blank string" do
      date_string = ""
      expect_raises Ledger::Parser::ParserException, "Unable to parse date: " do
        Ledger::Parser.new(date_string).parse_time
      end
    end

    it "fails with random other stuff" do
      date_string = "    Transaction"
      expect_raises Ledger::Parser::ParserException, "Unable to parse date: " do
        Ledger::Parser.new(date_string).parse_time
      end
    end

    it "fails with something that kind of looks like a date but isnt" do
      date_string = "2010/13/49 * Hello"
      expect_raises ArgumentError do
        Ledger::Parser.new(date_string).parse_time
      end
    end

    describe "#parse_cleared" do
      it "knows it's not cleared if it's words" do
        cleared_string = "Transaction Start"
        parsed_cleared = Ledger::Parser.new(cleared_string).parse_cleared
        parsed_cleared.should eq false 
      end

      it "can pull cleared out of the well formatted transaction" do
        cleared_string = "* Transaction Start"
        parsed_cleared = Ledger::Parser.new(cleared_string).parse_cleared
        parsed_cleared.should eq true
      end
    end

    describe "#parse_description" do
      it "takes the whole description" do
        description_string = "Transaction Start\n wow"
        parsed_description = Ledger::Parser.new(description_string).parse_description
        parsed_description.should eq "Transaction Start"
      end

      it "takes the whole description" do
        description_string = "\n wow"
        expect_raises Ledger::Parser::ParserException, "Must have a description" do
          Ledger::Parser.new(description_string).parse_description
        end
      end
    end

    describe "#parse_comment" do
      it "cares about whitespace" do
        comment_string = "; this is a comment\n"
        parsed_comment = Ledger::Parser.new(comment_string).parse_comment
        parsed_comment.should eq nil
      end

      it "doesn't find the comment when not whitespaced well whitespace" do
        comment_string = "    ; this is a comment\n"
        parsed_comment = Ledger::Parser.new(comment_string).parse_comment
        parsed_comment.should eq " this is a comment"
      end
    end

    describe "#parse_comments" do
      it "creates an array of the comments" do
        comment_string = "    ; this is a comment\n    Transaction:Actually"
        parsed_comment = Ledger::Parser.new(comment_string).parse_comments
        parsed_comment.should eq [" this is a comment"]
      end

      it "is an empty array if no comments" do
        comment_string = "Transaction:Here\n"
        parsed_comment = Ledger::Parser.new(comment_string).parse_comments
        parsed_comment.should eq [] of String
      end
    end
  end

  describe "#parse_entry" do
    it "creates an entry from a standard entry" do
      entry_line = "    Transaction:Entry  $12.00\n"
      parsed_entry = Ledger::Parser.new(entry_line).parse_entry
      parsed_entry.should eq Ledger::Transaction::Entry.new(account: "Transaction:Entry", value: 1200)
    end

    it "creates an entry from a negative entry" do
      entry_line = "    Transaction:Entry  $-12.00\n"
      parsed_entry = Ledger::Parser.new(entry_line).parse_entry
      parsed_entry.should eq Ledger::Transaction::Entry.new(account: "Transaction:Entry", value: -1200)
    end

    it "creates an entry from a negative entry with weird currency order" do
      entry_line = "    Transaction:Entry  -$12.00\n"
      parsed_entry = Ledger::Parser.new(entry_line).parse_entry
      parsed_entry.should eq Ledger::Transaction::Entry.new(account: "Transaction:Entry", value: -1200)
    end

    it "creates an entry if user was lazy and didn't type full value" do
      entry_line = "    Transaction:Entry  $12\n"
      parsed_entry = Ledger::Parser.new(entry_line).parse_entry
      parsed_entry.should eq Ledger::Transaction::Entry.new(account: "Transaction:Entry", value: 1200)
    end

    it "creates an entry with a nil value" do
      entry_line = "    Transaction:Entry\n"
      parsed_entry = Ledger::Parser.new(entry_line).parse_entry
      parsed_entry.should eq Ledger::Transaction::Entry.new(account: "Transaction:Entry", value: nil)
    end
  end
end
