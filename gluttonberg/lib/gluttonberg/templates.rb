require Pathname(__FILE__).dirname.expand_path / "templates" / "mixin"

module Gluttonberg
  module Templates
    def self.setup
      dir = Gluttonberg.config[:template_dir]
      unless File.exists?(dir)
        FileUtils.mkdir(dir)
        %w(layout pages editors).each {|d| FileUtils.mkdir(dir / d)}
      end
    end
    
    def self.root
      Gluttonberg.config[:template_dir]
    end
    
    def self.path_for(type)
      self.root / type
    end
  end
end
