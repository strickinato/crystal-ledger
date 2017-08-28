require "string_scanner"

class Ledger::Parser

  getter :buffer

  class ParserException< Exception; end

  def initialize(string : String)
    @buffer = StringScanner.new(string)
    @transactions = [] of Ledger::Transaction
  end

  def parse_transaction
    time = parse_time
    cleared = parse_cleared
    description = parse_description
    comment = parse_comment

    [ time, cleared, description, comment ]
  end

  def parse_time : Time
    maybe_year_string = @buffer.scan(/\d{4}\/\d{2}\/\d{2} /)
    if maybe_year_string.is_a?(String)
      Time::Format.new(pattern: "%Y/%m/%d").parse(maybe_year_string)
    else
      raise ParserException.new("Unable to parse date: #{maybe_year_string}")
    end
  end

  def parse_cleared : Bool
    maybe_cleared_string = @buffer.check(/\S /)
    if maybe_cleared_string == "* "
      @buffer.offset = @buffer.offset + 2
      true
    else
      false
    end
  end

  def parse_description : String
    maybe_description_string = @buffer.scan(/(\S.*)\n/)
    if maybe_description_string
      @buffer[1]
    else
      raise ParserException.new("Must have a description")
    end
  end

  def parse_comment : String | Nil
    maybe_comment_string = @buffer.scan(/    ;(.*)\n/)
    if maybe_comment_string
      @buffer[1]
    else
      nil
    end
  end
end
