# Turn on UTF-8 with this opaque assignment here
$KCODE = "UTF-8"

Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

use_orm :datamapper
use_test :rspec

dependency 'dm-is-tree',        "= 0.9.6"
dependency 'dm-observer',       "= 0.9.6"
dependency 'dm-is-list',        "= 0.9.6"
dependency 'dm-validations',    "= 0.9.6"
dependency 'dm-timestamps',     "= 0.9.6"
dependency 'dm-types',          "= 0.9.6"
dependency 'merb-haml',         "= 0.9.6"
dependency 'merb-assets',       "= 0.9.6"
dependency 'merb-action-args',  "= 0.9.6"
dependency 'merb_helpers',      "= 0.9.5"
dependency 'haml'
# Some additional load paths for auto-loading
# Merb.push_path(:lib, (Merb.root / "lib"), "**/*.rb")
dependency 'lib/core_ext'
dependency 'lib/admin_controller'
dependency 'lib/content'

Merb::Config.use do |c|
  c[:session_id_key] = 'low_fat_content_management'
  c[:session_secret_key]  = 'cbf85572c84cd403a94c32a68e50775f642c4f59'
  c[:session_store] = 'cookie'
end

Merb::BootLoader.after_app_loads do
  # This is a temporary fix, to force DM to load all the association properties
  descendants = DataMapper::Resource.descendants.dup
  descendants.each do |model|
    descendants.merge(model.descendants) if model.respond_to?(:descendants)
  end
  descendants.each do |model|
    model.relationships.each_value { |r| r.child_key if r.child_model == model }
  end
end

