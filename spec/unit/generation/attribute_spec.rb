describe ToFactory::Generation::Attribute do
  let(:attribute) { ToFactory::Generation::Attribute.new(:some_attributes, {:a => 1}) }

  describe "#to_s" do
    it do
      expect(attribute.to_s).to include "some_attributes({:a => 1})"
    end
  end

  describe "#inspect_value" do
    it do
      expect(attribute.inspect_value({:a => 1})).to eq "({:a => 1})"
    end

    it do
      hash = ActiveSupport::OrderedHash.new
      hash[{"with" => :hash}] = "keys"
      hash[2] = "integers"
      hash[:a] = {:nested => "hash"}

      expected = '({{"with" => :hash} => "keys", 2 => "integers", :a => {:nested => "hash"}})'

      expect(attribute.inspect_value(hash)).to eq expected
    end

    it "handles arrays correctly" do
      expected = "[1, 2, :a, \"4\"]"

      input = [1, 2, :a, "4"]
      expect(attribute.format(input, false)).to eq expected
    end
  end

  if RUBY_VERSION =~ /\A1\.8/
    it "alters attributes that are unparseable by RubyParser" do
      #when reparsing the generated files, we don't want the parser itself
      #to raise an exception, rather than fix RubyParser now, a hotfix is to
      #warn about these attributes and replace them with something parseable
      value = File.read("./spec/support/ruby_parser_exception_causing_string.rb")
      expect(lambda{RubyParser.new.parse(value)}).to raise_error StringScanner::Error
      result = attribute.inspect_value(value)
      expect(lambda{RubyParser.new.parse(result)}).not_to raise_error
      expect(result).to match /ToFactory: RubyParser exception/
    end
  end
end
