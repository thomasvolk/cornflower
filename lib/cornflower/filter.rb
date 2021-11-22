module Cornflower
  module Filter
    def self.tags(*tags)
      TagFilter.new tags
    end

    def self.invert(filter)
      InvertFilter.new filter
    end

    class AbstractFilter
      def filter(node)
        raise "not implemented"
      end
    end

    class PassThroughFilter < AbstractFilter
      def filter(node)
        true
      end
    end

    class InvertFilter < AbstractFilter
      def initialize(delegate)
        @delegate = delegate
      end
      def filter(node)
        !@delegate.filter(node)
      end
    end

    class TagFilter < AbstractFilter
      def initialize(tags)
        @tags = tags
      end

      def filter(node)
        return !node.attributes.fetch(:tags, []).filter {|t| @tags.include? t }.empty?
      end
    end
  end
end