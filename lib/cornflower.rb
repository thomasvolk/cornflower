module Cornflower
  VERSION = '0.0.1'

  class AbstractNode
    def initialize(model)
      @children = {}
      @sealed = false
      @model = model
    end

    def add_node(name, attributes = {}, &block)
      if @children.has_key? name
        return @children[name]
      end
      if @sealed
        raise NoMethodError.new name
      else        
        n = Node.new @model, name, attributes
        @children[name] = n
        if block_given?
          n.instance_eval(&block)
        end
        return n
      end
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
    attr_reader :name, :sealed, :attributes

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
      self.instance_eval(&block)
      self.sealed = true
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
