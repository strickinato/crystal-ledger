class Ledger::Importer::Venmo < Ledger::Importer::Base
  header date, "Datetime", ->(time : String) { Time.new(2017,9,3) }
  always cleared, true
  header description, "Note", ->(description : String) { description }

  custom value, ->(row : CSV | String) do
    amount = row["Amount (total)"]
    string_amount = amount.sub({ ',' => '', ' ' => ''}),
    Ledger::Value.from_string(string_amount)
  end

  custom comment, ->(row : CSV | String) do
    from = row["From"]
    to = row["To"]
    "Venmo from: #{from} to #{to}"
  end

  def account
    "Assets:Liquid:Venmo"
  end
end
