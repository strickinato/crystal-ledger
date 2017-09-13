require "string_scanner"

class Ledger::Parser

  getter :buffer, :transactions

  class ParserException< Exception; end

  def self.from_file(filename) : Ledger::Parser
    new File.read(filename)
  end

  def initialize(string : String)
    @buffer = StringScanner.new(string)
    @transactions = [] of Ledger::Transaction
  end

  def parse_transactions
    while !@buffer.eos?
      if @buffer.check(/\d{4}/)
        @transactions << parse_transaction
      else
        @buffer.scan_until(/\n/) || break
      end
    end
  end

  def parse_transaction
    date = parse_time
    cleared = parse_cleared
    description = parse_description
    comments = parse_comments
    entries = parse_entries

    Ledger::Transaction.new(
      date: date,
      cleared: cleared,
      description: description,
      comments: comments,
      tags: [] of String,
      entries: entries
    )
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
      raise ParserException.new("Must have a description: #{@buffer.inspect}")
    end
  end

  def parse_comments : Array(String)
    comments = [] of String
    while true
      comment = parse_comment
      if comment.is_a?(String)
        comments.push comment
      else
        break
      end
    end

    comments.compact
  end

  def parse_comment : String | Nil
    maybe_comment_string = @buffer.scan(/    ;(.*)\n/)
    if maybe_comment_string
      @buffer[1]
    else
      nil
    end
  end

  def parse_entries
    entries = [] of Ledger::Transaction::Entry
    while true
      if @buffer.check(/    .*\n/)
        entry = parse_entry
        if entry.is_a?(Ledger::Transaction::Entry)
          entries.push entry
        end
      else
        return entries
      end
    end

    entries.compact
  end

  def parse_entry : Ledger::Transaction::Entry | Nil
    entry_string = @buffer.scan_until(/\n/)
    if entry_string.is_a?(String)
      if match = /    (.+(?=  ))\ *([$0-9-\.]+)\n/.match(entry_string)
        account = match[1].strip
        value = parse_value(match[2].strip)
        Ledger::Transaction::Entry.new(account: account, value: value)

      elsif match = /    (.+(?=\ \ )\ *)\n/.match(entry_string)
        account = match[1].strip
        value = nil
        Ledger::Transaction::Entry.new(account: account, value: nil)

      elsif match = /    (.+)\n/.match(entry_string)
        account = match[1].strip
        value = nil
        Ledger::Transaction::Entry.new(account: account, value: nil)

      else
        raise ParserException.new("Must have two spaces before value")
      end
    end
  end

  def parse_value(value : String) : Int32
    if match = /-\$(\d+\.\d+)/.match(value)
      - Int32.new(match[1].delete('.'))
    elsif match = /\$-(\d+\.\d+)/.match(value)
      - Int32.new(match[1].delete('.'))
    elsif match = /-\$(\d+)/.match(value)
      - Int32.new(match[1]) * 100
    elsif match = /\$-(\d+)/.match(value)
      - Int32.new(match[1]) * 100
    elsif match = /\$(\d+\.\d+)/.match(value)
      Int32.new(match[1].delete('.'))
    elsif match = /\$(\d+)/.match(value)
      Int32.new(match[1]) * 100
    else
      raise ParserException.new("Not a legit value: #{@buffer.inspect}")
    end
  end
end
