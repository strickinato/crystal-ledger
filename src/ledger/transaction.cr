struct Ledger::Transaction
  class InvalidEntriesException < Exception; end

  property :date, :description, :tags, :comments, :entries

  struct Entry
    property :account, :value
    def initialize(@account : String, @value : Int32 | Nil)
    end
  end

  def initialize(
        @date : Time,
        @cleared : Bool,
        @description : String,
        @tags : Array(String),
        @comments : Array(String),
        @entries : Array(Entry)
      )
    validate_at_least_two_entries
    validate_at_most_one_blank_entry
    validate_entries_balance
  end

  def cleared?
    @cleared
  end

  private def blank_entries
    @entries.select do |entry|
      entry.value.nil?
    end
  end

  private def explicit_values : Array(Int32)
    entries.compact_map { |entry| entry.value }
  end

  private def validate_at_least_two_entries
    if @entries.size < 2
      raise InvalidEntriesException.new("There needs to be at least two entries")
    end
  end

  private def validate_at_most_one_blank_entry
    if blank_entries.size > 1
      raise InvalidEntriesException.new("Can't have multiple blank entries")
    end
  end

  private def validate_entries_balance
    if entries.size == explicit_values.size
      if explicit_values.sum > 0.001 || explicit_values.sum < -0.001
        raise InvalidEntriesException.new("Debits and Credits don't balance to 0.00")
      end
    end
  end
end
