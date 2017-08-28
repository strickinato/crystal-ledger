require "spec"
require "../../src/ledger/parser"

describe Ledger::Parser do
  well_formatted_transaction = <<-LEDGER
2017/06/15 * Taco Truck
    ;here's a comment
    Liabilities:CreditCard:Chase:SapphireReserve       -$12.00
    Expenses:Food:Lunch Buys
LEDGER

  describe "#parse_transaction" do
    it "should handle transactions" do
      parser = Ledger::Parser.new(well_formatted_transaction)
      parsed_transaction = parser.parse_transaction
      parsed_transaction.should eq [ Time.new(2017, 6, 15), true, "Taco Truck", "here's a comment" ]
      parser.buffer.offset.should eq 46
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
  end
end