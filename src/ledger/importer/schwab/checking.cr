class Ledger::Importer::Schwab::Checking < Ledger::Importer::Base
  header date, "Date", ->(time : String) { Time.parse(time[0,9], "%m/%d/%Y") }
  always cleared, true
  header description, "Description", ->(description : String) { description }
  custom value, ->(row : String) do
    withdrawal = row["Withdrawal (-)"]
    deposit = row["Deposit (+)"]

    if withdrawal.length > 0
      Ledger::Value.from_string(amount)
    else
      - Ledger::Value.from_string(amount)
    end
  end

  always comment, [] of String

  def account
    "Assets:Liquid:Schwab:Checking"
  end
end
