module Cornflower
  module Filter
    def self.tags(*tags)
      if tags.empty?
        return ->(c) { true }
      else
        return ->(c) { !c.attributes.fetch(:tags, []).filter {|t| tags.include? t }.empty? }
      end
    end
  end
end