module ToFactory
  class AutoGenerator
    def initialize(m=ModelFinder.new, f=FileWriter.new)
      @model_finder = m.is_a?(String) ? ModelFinder.new(m) : m
      @file_writer  = f.is_a?(String) ? FileWriter .new(f) : f
    end

    def all!
      instances = @model_finder.all

      factory_definitions = instances.each_with_object({}) do |record, result|
        result[record.class.name.underscore.to_sym] = record.to_factory
      end

      @file_writer.write(factory_definitions)
    end
  end

  class ModelFinder
    def initialize(path="./app/models/path")
      @path = File.expand_path(path)
    end

    def all
      klasses = []

      Dir.glob("#{@path}/**/*.rb").each do |file|
        File.readlines(file).each do |f|
          if match = f.match(/class (.*) ?</)
            require file
            klass = eval(match[1]) rescue nil
            klasses << klass.first if klass && klass.ancestors.include?(ActiveRecord::Base)
          end
        end
      end

      klasses
    end
  end

  class FileWriter
    def initialize(path="./spec/factories")
      @path = path
      FileUtils.mkdir_p(@path)
    end

    def write(definitions)
      definitions.each do |name, definition|
        mkdir(name) if name.to_s["/"]
        File.open(File.join(@path, "#{name}.rb"), "w") do |f|
          f << definition
        end
      end
    end

    private

    def mkdir(name)
      dir = name.to_s.split("/")[0..-2]
      FileUtils.mkdir_p File.join(@path, dir)
    end
  end
end