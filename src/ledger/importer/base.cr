require "csv"

# The abstract `Ledger::Importer::Base` class is used to define importers
# that can be designed to convert arbitrary CSV files into ledger transactions.
#
# The `header` macro is used on subclasses to map CSV headers to the necessary
# fields for transactions depending on your bank.
abstract class Ledger::Importer::Base
  @transactions : Array(Ledger::Transaction)
  getter :transactions

  # You should be categorizing your own ledger transactions so you know what's
  # good, so by default, we don't write a category.
  NOT_YET_SORTED = "???"

  # Simply initiallizes the importer creating a list
  # of transactions of completely crapping out.
  def initialize(@csv : String | IO)
    @transactions = parse_csv CSV.new(csv, headers: true)
  end

  # This generates your `.ledger` string!
  def as_ledger : String
    @transactions.reverse.map {|t| t.to_string }.join("\n")
  end

  # This is where the magic happens
  #
  # pass in the name of the transaction field, which should be one of:
  #   * `date`
  #   * `cleared`
  #   * `description`
  #   * `value`
  #
  # also pass in the string representing the CSV header you care about
  #
  # also pass in a lamda that converts the csv string to the field you care about.
  # This is where you can inject any logic you'd like to mutate the string
  #
  #```
  #class MyClass < Ledger::Importer::Base
  #  header date, "Trans Posted", ->(time : String) { Time.parse(time, "%m/%d/%Y") }
  #  header cleared, "Post Date", ->(time : String) { true }
  #  header description, "Description", ->(description : String) { description }
  #  header value, "Amount", ->(amount : String) { convert_money(amount) }
  #  def account
  #    "Expenses:MyAccount"
  #  end
  #end
  #```
  macro header(name, header, block)
    def {{name}}(row)
      {{block}}.call(row[{{header}}])
    end
  end

  private abstract def account : String
  private abstract def date(strformat : String) : Time
  private abstract def cleared(strformat : String) : Boolean
  private abstract def description(description : String)
  private abstract def value(value : String)

  private def make_entries(row) : Array(Ledger::Transaction::Entry)
    [ Ledger::Transaction::Entry.new(account: account, value: value(row)),
      Ledger::Transaction::Entry.new(account: NOT_YET_SORTED, value: nil)
    ]
  end

  private def parse_csv(csv : CSV) : Array(Ledger::Transaction)
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
end
