require Pathname(__FILE__).dirname.expand_path / "library" / "attachment_mixin"

module Gluttonberg
  module Library
    TYPE_MATCHERS = {
      'audio'    => /audio/,
      'image'    => /image/,
      'video'    => /video/,
      'document' => /[text|pdf]/,
      'archive'  => /binary/,
      'binary'   => /binary/
    }
    TYPES = (TYPE_MATCHERS.collect {|k, v| k}).sort
    
    @@assets_root = nil
    @@asset_dirs  = {}
    
    # Is run when the slice is loaded. It makes sure that all the required 
    # directories for storing assets are in the public dir, creating them if
    # they are missing. It also stores the various paths so they can be 
    # retreived using the assets_dir method.
    def self.setup
      Merb.logger.info("Gluttonberg is checking for asset folders")
      @@assets_root = Merb.dir_for(:public) / "assets"
      FileUtils.mkdir(assets_dir) unless File.exists?(assets_dir)
      # Set up a directory for each type and store a reference to each.
      TYPES.each do |type|
        type_dir = assets_dir / type.to_s.pluralize
        @@asset_dirs[type] = type_dir
        FileUtils.mkdir(type_dir) unless File.exists?(type_dir)
      end
    end
    
    # Without any arguments it simply returns the assets root. With a symbol,
    # it returns the matching path
    #
    #   Library.assets_dir(:images) # => "...myapp/public/assets/images"
    def self.assets_dir(type = :root)
      if type == :root
        @@assets_root
      else
        @@asset_dirs[type]
      end
    end
  end
end