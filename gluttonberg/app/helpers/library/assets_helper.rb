module Merb
  module Gluttonberg
    module Library
      module AssetsHelper

        # Returns an AssetCollection (either by finding a matching existing one or creating a new one)
        # requires a hash with the following keys
        #   do_new_collection: If not present the method returns nil and does nothing
        #   new_collection_name: The name for the collection to return.
        def find_or_create_asset_collection_from_hash(param_hash)
          # Create new AssetCollection if requested by the user
          if param_hash
            if param_hash.has_key?('do_new_collection')
              if param_hash.has_key?('new_collection_name')
                unless param_hash['new_collection_name'].blank?
                  # Retireve the existing AssetCollection if it matches or create a new one
                  the_collection = ::Gluttonberg::AssetCollection.first(:name => param_hash['new_collection_name'])
                  unless the_collection
                    the_collection = ::Gluttonberg::AssetCollection.create(:name => param_hash['new_collection_name'])
                  end

                  the_collection                    
                end
              end
            end
          end
        end

      end
    end # Library
  end # Gluttonberg
end # Merb