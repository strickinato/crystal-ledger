require "csv"

abstract class Ledger::Importer::Base
  @transactions : Array(Ledger::Transaction)
  getter :transactions

  NOT_YET_SORTED = "???"

  def initialize(@csv : String | IO)
    @transactions = parse_csv CSV.new(csv, headers: true)
  end

  def parse_csv(csv : CSV) : Array(Ledger::Transaction)
    transactions = [] of Ledger::Transaction
    csv.each do |row|
      transactions << Ledger::Transaction.new(
        date: date(row),
        cleared: cleared(row),
        description: description(row),
        entries: make_entries(row),
        tags: [] of String,
        comments: [] of String
      )
    end
    transactions
  end

  def make_entries(row) : Array(Ledger::Transaction::Entry)
    [ Ledger::Transaction::Entry.new(account: account, value: value(row)),
      Ledger::Transaction::Entry.new(account: NOT_YET_SORTED, value: nil)
    ]
  end

  def print
    @transactions.reverse.map {|t| t.to_string }.join("\n")
  end

  macro header(name, header, block)
    def {{name}}(row)
      {{block}}.call(row[{{header}}])
    end
  end

  abstract def account
  abstract def date(string)
  abstract def cleared(string)
  abstract def description(string)
  abstract def value(row)
end
