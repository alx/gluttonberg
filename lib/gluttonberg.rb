module Gluttonberg
  module Slices
    class << self; attr_accessor :slices end
    @slices = Hash.new {|h, k| h[k] = {}}
    
    # Register a name and the module
    # Mixin any extensions we want to offer
    def self.register(name, klass, opts)
      name = name.to_sym
      slices[name][:class] = klass
      # These are the default configurations which users can over-ride using
      # the slice config in an after_app_loads block
      slices[name][:config] = opts 
      klass.include(ModuleMixin)
    end
    
    def self.[](module_name)
      slices[module_name]
    end
    
    
    def self.config
      slices.inject({}) {|memo, k, v| memo[k] = v[:config]}
    end
    
    # This hold the various extensions we want to offer to the slice that
    # registers itself. Currently this is just a stub.
    module ModuleMixin
      
    end
  end
end