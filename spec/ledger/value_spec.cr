require "spec"
require "../../src/ledger"

describe Ledger::Value do
  describe ".from_string" do
    tests =
      {
        "minus then dollar sign" => { "-$1.99", -199 },
        "minus then dollar whole number" => { "-$3", -300 },
        "dollar then minus" => { "$-3.42", -342 },
        "dollar then minus whole number" => { "$-3", -300 },
        "dollar" => { "$3.42", 342 },
        "dollar whole number" => { "$30", 3000 },
        "no dollar sign" => { "13.41", 1341 },
        "no dollar sign whole number " => { "13", 1300 },
        "minus no dollar sign" => { "-13.41", -1341 },
        "minus no dollar sign whole number " => { "-13", -1300 },
      }
    tests.each do |test_name, test_values|
      it test_name do
        Ledger::Value.from_string(test_values.first).should eq test_values.last
      end
    end

    bad_scenarios =
      {
        "three after decimal" => "-1.9$99",
        "dollar sign weirdly in middle" => "-$1.999",
      }

    bad_scenarios.each do |test_name, test_value|
      it test_name do
        expect_raises(Ledger::Parser::ParserException, "") do
          Ledger::Value.from_string(test_value)
        end
      end
    end
  end
end
