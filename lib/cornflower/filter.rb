module Cornflower
  module Filter
    def self.tags(tags, invert = false)
      f = TagFilter.new tags
      if invert
        self.invert f
      else
        f
      end
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

    class StopFilter < AbstractFilter
      def filter(node)
        false
      end
    end

    class FilterChain < AbstractFilter
      def initialize(filter_list)
        @filter_list = filter_list
      end
      def filter(node)
        for f in @filter_list do
          if !f.filter(node)
            return false
          end
        end
        return true
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

      def filter(item)
        return !item.tags.filter {|t| @tags.include? t }.empty?
      end
    end
  end
end