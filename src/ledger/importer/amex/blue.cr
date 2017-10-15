class Ledger::Importer::Amex::Blue < Ledger::Importer::Base
  index date, 0, ->(time : String) { Time.parse(time[0,9], "%m/%d/%Y") }
  index cleared, 1, ->(time : String) { true }
  index description, 2, ->(description : String) { description }
  index value, 7, ->(amount : String) { Ledger::Value.from_string(amount) }

  always comment, [] of String

  def account
    "Liabilities:CreditCard:AmEx:Blue"
  end
end
