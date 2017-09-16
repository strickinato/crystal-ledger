class Ledger::Importer::ChaseReserve < Ledger::Importer::Base

  map_header date, "Trans Date", ->(time : String) { Time.parse(time, "%m/%d/%Y") }

  map_header cleared, "Post Date", ->(time : String) { !!Time.parse(time, "%Y/%m/%d") }

  map_header description, "Description", ->(description : String) { description }

  map_header value, "Amount", ->(amount : String) { Ledger::Value.from_string(amount) }

  def account
    "Liabilities:CreditCard:Chase:SapphireReserve"
  end
end
