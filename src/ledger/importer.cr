require "csv"

class Ledger::Importer
  @transactions : Array(Time)

  getter :transactions

  def initialize(@csv : String | IO)
    @transactions = parse_csv CSV.new(csv, headers: true)
  end

  def parse_csv(csv : CSV) : Array(Time)
    transactions = [] of Time
    csv.each do |row|
      transactions << date(row)
        # cleared: row[cleared],
        # descriptions: row[descriptions],
        # tags: row[tags],
        # comments: row[comments],
        # entries: row[entries],
    end
    transactions
  end

  def print
    @transactions.to_string.join("\n")
  end

  macro map_header(name, header, block)
    def {{name}}(row)
      {{block}}.call(row[{{header}}])
    end
  end

  map_header date, "Date", ->(time : String) { Time.parse(time, "%Y-%m-%d") }
end
