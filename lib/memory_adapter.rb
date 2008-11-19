require "dm-core"
# this and the SimpleAdapter is basically the 
# dm-core/adapter/in_memory_adapter.rb most credits go dm-core. 
# there are few bug fixes and enhancements.
module DataMapper
  module Adapters
    class MemoryAdapter < SimpleAdapter

      public

      # @overwrite from SimpleAdapter
      def initialize(name, uri_or_options)
        super

        @records = Hash.new { |hash,model| hash[model] = Array.new }
        @ids = Hash.new { |hash,model| hash[model] = 0 }
      end

      # @overwrite from SimpleAdapter
      def create_resource(resource)
        @records[resource.model] << resource
        resource.id = (@ids[resource.model] += 1) if resource.key.size == 1 
        # and resource.key[0].serial?
        resource
      end

      # @overwrite from SimpleAdapter
      def update_resource(resource, attributes)
        attributes.each do |property, value|
          property.set!(resource, value)
        end
      end

      # @overwrite from SimpleAdapter
      def delete_resource(resource)
        records = @records[resource.model]
        records.delete(resource)
      end

      # @overwrite from SimpleAdapter
      def read_resource(query)        
        read(query, false)
      end

      # @overwrite from SimpleAdapter
      def read_resources(query)        
        read(query, true)
      end

      private

      # helper to read either one or many resources matching the given query
      def read(query, many)
        model      = query.model
        conditions = query.conditions
        
        match_with = many ? :select : :detect

        result = @records[model].send(match_with) do |resource|
          filter_resource(resource, conditions)
        end

        # TODO Sort

        # TODO Limit

        return result
      end
    end
  end
end
