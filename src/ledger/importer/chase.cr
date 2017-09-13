class Ledger::Importer::Chase < Ledger::Importer::Base

  map_header date, "Trans Date", ->(time : String) { Time.parse(time, "%m/%d/%Y") }

  map_header cleared, "Post Date", ->(time : String) { !!Time.parse(time, "%Y/%m/%d") }

  map_header description, "Description", ->(description : String) { description }

  map_header value, "Ammount", ->(amount : String) { Ledger::Parser.parse_value(amount) } # TODO move to shared utility class

  def account
    "Liabilities:CreditCard:Chase:SapphireReserve"
  end
end
