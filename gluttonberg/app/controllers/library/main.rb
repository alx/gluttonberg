module Gluttonberg
  module Library
    class Main < Gluttonberg::Application
      def index
        # Get the latest assets, ensuring that we always grab at least 15 records
        range = ((Time.now - 24.hours)..Time.now)
        @assets = Asset.all(:updated_at => range, :order => [:updated_at.asc], :limit => 15)
        # Collections
        @collections = AssetCollection.all(:order => [:name.desc])
        render
      end
    end
  end
end