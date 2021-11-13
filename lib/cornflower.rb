module Cornflower

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

    def walker
      ModelWalker.new self
    end
  end

  module Filter
    def self.tags(*tags)
      ->(c) { !c.attributes.fetch(:tags, []).filter {|t| tags.include? t }.empty? }
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

    def to_s
      d = ""
      unless @description.nil?
        d = " | #{@description}"
      end
      "Relation(#{@from} --> #{@to}#{d})"
    end
  end

  class ModelWalker
    def initialize(model)
      @model = model
      @on_begin_node = proc {|c| }
      @on_end_node = proc {|c| }
      @on_relation = proc {|r| }
    end

    def on_begin_node(&block)
      @on_begin_node = block
    end

    def on_end_node(&block)
      @on_end_node = block
    end

    def on_relation(&block)
      @on_relation = block
    end

    def walk(filter = ->(c) {true})
      traverse_nodes(filter, 0, @model.children)
      @model.relations.each { |r|
        if filter.call(r.from) && filter.call(r.to)
          @on_relation.call(r)
        end
      }
    end

    private

    def traverse_nodes(filter, level, nodes)
      nodes.each { |n|
        filter_match = filter.call(n)
        new_level = level
        if filter_match
          new_level = new_level + 1
          @on_begin_node.call(n, level)
        end
        traverse_nodes(filter, new_level, n.children)
        if filter_match
          @on_end_node.call(n, level)
        end
      }
    end

  end


end
