module ToFactory
  class Representation
    delegate :attributes, :to => :record
    attr_accessor :klass, :name, :parent_name, :definition, :hierarchy_order, :record

    def self.from(options)
      OptionsParser.new(options).get_instance
    end

    def initialize(name, parent_name, definition=nil, record=nil)
      @name, @parent_name, @definition, @record =
        name.to_s, parent_name.to_s, definition, record
    end

    def inspect
      "#<ToFactory::Representation:#{object_id} @name: #{@name.inspect}, @parent_name: #{@parent_name.inspect}, @klass: #{klass_name_inspect}>"
    end

    def klass_name_inspect
      @klass.name.inspect rescue "nil"
    end

    def definition
      @definition ||= ToFactory::Generation::Factory.new(self).to_factory
    end
  end
end
