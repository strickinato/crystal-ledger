abstract class Ledger::Importer::Chase < Ledger::Importer::Base
  header date, "Trans Date", ->(time : String) { Time.parse(time, "%m/%d/%Y") }
  header cleared, "Post Date", ->(time : String) { true }
  header description, "Description", ->(description : String) { description }
  header value, "Amount", ->(amount : String) { Ledger::Value.from_string(amount) }
end
