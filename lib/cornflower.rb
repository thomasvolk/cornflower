module Cornflower

  module Tags
    def tags
      self.get_tags
    end
  end

  class AbstractNode

    def initialize(model)
      @children = {}
      @model = model
    end

    def method_missing(name, attributes = {}, &block)
      n = nil
      if @children.has_key? name
        n = @children[name]
        n.attributes = n.attributes.merge(attributes)
      end
      if n == nil
        if @model.sealed
          raise NoMethodError.new name
        end  
        n = Node.new @model, name, attributes
        @children[name] = n
      end
      if block_given?
        n.instance_eval(&block)
      end
      n
    end

    def children
      @children.values
    end
  end

  class Node < AbstractNode
    include Tags
    attr_reader :name
    attr_accessor :attributes

    def initialize(model, name, attributes = {})
      @name = attributes.fetch(:name, name)
      @attributes = attributes
      super(model)
    end

    def get_tags
      @attributes.fetch(:tags, [])
    end

    def <<(from)
      @model.add_relation from, self
    end

    def >>(to)
      @model.add_relation self, to
    end

  end

  class Model < AbstractNode
    attr_reader :root, :relations, :sealed, :config

    def initialize(config = {}, &block)
      @relations = []
      @sealed = false
      @config = config
      super(self)
      if block_given?
        add(&block)
      end
    end

    def load(filename)
      load_string File.read(filename)
      self
    end

    def load_string(text)
      self.instance_eval text
      self
    end

    def add(&block)
      self.instance_eval(&block)
      self
    end

    def add_relation(from, to)
      r = Relation.new from, to
      @relations << r
      r
    end

    def sealed=(val)
      @sealed = val
    end
  end

  class Relation
    include Tags
    attr_reader :from, :to, :attributes
    attr_accessor :description

    def initialize(from, to)
      @from = from
      @to = to
      @description = nil
      @attributes = {}
    end

    def get_tags
      common_node_tags = @from.tags.filter { |t| @to.tags.include? t }
      if @attributes.has_key? :tags
        return @attributes[:tags].filter { |t| common_node_tags.include? t }
      end
      common_node_tags
    end

    def |(description)
      @description = description
      self
    end

    def <(attributes)
      @attributes = @attributes.merge(attributes)
      self
    end

    def has_description?
      @description != nil
    end
  end

end
