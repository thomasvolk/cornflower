module Cornflower
  module Filter
    def self.tags(tags, exclude = false)
      TagFilter.new tags, exclude
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

    class TagFilter < AbstractFilter
      def initialize(tags, exclude = false)
        @tags = tags
        @exclude = exclude
      end

      def filter(item)
        matching_tags = get_tags(item).filter {|t| @tags.include? t }
        @exclude ? matching_tags.empty? : !matching_tags.empty?
      end

      private

      def fetch_tags(node)
        node.attributes.fetch(:tags, [])
      end

      def get_tags(item)
        tags = []
        if item.is_a? Relation
          if @exclude
            get_all_tags_for_relation item
          else
            get_common_tags_for_relation item
          end
        else
          fetch_tags item
        end
      end

      def get_all_tags_for_relation(relation)
        tags = fetch_tags(relation.from)
        tags += fetch_tags(relation.to)
        tags += fetch_tags(relation)        
        tags.uniq
      end

      def get_common_tags_for_relation(relation)
        common_tags = fetch_tags(relation.from).filter {
          |t| fetch_tags(relation.to).include? t 
         }
        if relation.attributes.has_key? :tags
          common_tags = relation.attributes[:tags].filter { |t| common_tags.include? t }
        end
        common_tags
      end
    end
  end
end