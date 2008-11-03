require Pathname(__FILE__).dirname.expand_path / "library" / "attachment_mixin"

module Gluttonberg
  module Library
    # TODO: Define a set of fallbacks for examining extensions if we match
    # against an ambigous pattern e.g. application/octet-stream
    #
    # Also need to account for particular types that are wierdly labelled.
    # For example ogg files have the mime-type: application/ogg
    CATEGORY_PATTERNS = {
      'audio'    => %r{^audio/},
      'image'    => %r{^image/},
      'video'    => %r{^video/},
      'document' => %r{[text/|/pdf|/excel|/mspowerpoint|/msword|/postscript]},
      'archive'  => %r{[zip|gzip|tar]},
      'binary'   => %r{^binary/}
    }
    CATEGORIES = CATEGORY_PATTERNS.keys.sort
    
    # Types are the actual document type rather than the broad category i.e.
    # a word document belongs in the document category, but the actual type
    # itself is "word"
    TYPE_PATTERNS = {
      "Word"        => ["doc",          %r{/msword}],
      "Powerpoint"  => ["ppt",          %r{/mspowerpoint}],
      "PDF"         => ["pdf",          %r{/pdf}],
      "Excel"       => ["xl",           %r{/excel}],
      "PNG"         => ["png",          %r{/png}],
      "JPEG"        => ["jpg", "jpeg",  %r{/png}],
      "GIF"         => ["gif",          %r{/gif}]
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
      CATEGORIES.each do |category|
        category_dir = assets_dir / category.pluralize
        @@asset_dirs[category] = category_dir
        FileUtils.mkdir(category_dir) unless File.exists?(category_dir)
      end
    end
    
    # Without any arguments it simply returns the assets root. With a symbol,
    # it returns the matching path
    #
    #   Library.assets_dir(:images) # => "...myapp/public/assets/images"
    def self.assets_dir(category = :root)
      if category == :root
        @@assets_root
      else
        @@asset_dirs[category]
      end
    end
  end
end