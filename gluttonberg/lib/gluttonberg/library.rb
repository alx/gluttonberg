require Pathname(__FILE__).dirname.expand_path / "library" / "attachment_mixin"

module Gluttonberg
  module Library
    # TODO: Define a set of fallbacks for examining extensions if we match
    # against an ambigous pattern e.g. application/octet-stream
    #
    # Also need to account for particular types that are wierdly labelled.
    # For example ogg files have the mime-type: application/ogg
    TYPE_PATTERNS = {
      'audio'    => %r{^audio/},
      'image'    => %r{^image/},
      'video'    => %r{^video/},
      'document' => %r{[text/|/pdf|/excel|/mspowerpoint|/msword|/postscript]},
      'archive'  => %r{[zip|gzip|tar]},
      'binary'   => %r{^binary/}
    }
    TYPES = TYPE_PATTERNS.keys.sort
    
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