module Cornflower
  VERSION = '0.0.1'

  class AbstractNode
    def initialize(model)
      @children = {}
      @sealed = false
      @model = model
    end

    def add_node(name, attributes = {}, &block)
      n = nil
      if @children.has_key? name
        n = @children[name]
        n.attributes = n.attributes.merge(attributes)
      end
      if n == nil
        if @sealed
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

    def sealed=(val)
      @sealed = val
      @children.each {|n, c| c.sealed = val}
    end

    alias method_missing add_node

  end

  class Node < AbstractNode
    attr_reader :name, :sealed
    attr_accessor :attributes

    def initialize(model, name, attributes = {})
      @name = attributes.fetch(:name, name)
      @attributes = attributes
      super(model)
    end

    def <<(from)
      @model.add_relation from, self
    end

    def >>(to)
      @model.add_relation self, to
    end

  end

  class Model < AbstractNode
    attr_reader :root, :relations

    def initialize(&block)
      @relations = []
      super(self)
      add(&block)
    end

    def add(&block)
      self.instance_eval(&block)
    end

    def add_relation(from, to)
      r = Relation.new from, to
      @relations << r
      r
    end 
  end

  class Relation
    attr_reader :from, :to
    attr_accessor :description

    def initialize(from, to)
      @from = from
      @to = to
      @description = nil
    end

    def |(description)
      @description = description
      self
    end

    def has_description?
      @description != nil
    end
  end

end
