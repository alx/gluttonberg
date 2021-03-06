helpers = Pathname(__FILE__).dirname.expand_path / "helpers"
require helpers / "content"
require helpers / "assets"
require helpers / "public"
require helpers / "admin"

module Gluttonberg
  module Helpers
    def self.setup
      [Assets, Admin, Public, Content].each do |helper|
        Merb::GlobalHelpers.send(:include, helper)
      end
    end
  end
end
