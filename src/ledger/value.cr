module Ledger
  module Value
    def self.from_string(value : String) : Int32
      if match = /^-\$(\d+)\.(\d{2})$/.match(value)
        - ((Int32.new(match[1]) * 100) + Int32.new(match[2]))
      elsif match = /^\$-(\d+\.\d{2})$/.match(value)
        - Int32.new(match[1].delete('.'))
      elsif match = /^-\$(\d+)$/.match(value)
        - Int32.new(match[1]) * 100
      elsif match = /^\$-(\d+)$/.match(value)
        - Int32.new(match[1]) * 100
      elsif match = /^\$(\d+\.\d{2})$/.match(value)
        Int32.new(match[1].delete('.'))
      elsif match = /^\$(\d+)$/.match(value)
        Int32.new(match[1]) * 100
      elsif match = /^(\d+)\.(\d{2})$/.match(value)
        Int32.new(match[1]) * 100 + Int32.new(match[2])
      elsif match = /^(\d+)$/.match(value)
        Int32.new(match[1]) * 100
      elsif match = /^-(\d+)\.(\d{2})$/.match(value)
        - Int32.new(match[1]) * 100 - Int32.new(match[2])
      elsif match = /^-(\d+)$/.match(value)
        - Int32.new(match[1]) * 100
      else
        raise Ledger::Parser::ParserException.new("Not a legit value: #{value}")
      end
    end
  end
end
