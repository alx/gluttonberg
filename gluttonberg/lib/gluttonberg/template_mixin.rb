module Gluttonberg
  module TemplateMixin
    def self.included(klass)
      class << klass; attr_accessor :template_type; end
    end
    
    # Returns a specific template, or alternately returns a default.
    def template_for(opts = {})
      # A bunch of potential matches in order of preference.
      candidates = if Gluttonberg.localized?
        puts "WTF?"
        # Locale and dialect
        # Locale only
        # Default
        [
          "#{filename}.#{opts[:locale].slug}.#{opts[:dialect].code}.#{opts[:format]}",
          "#{filename}.#{opts[:locale].slug}.#{opts[:format]}",
          "#{filename}.#{opts[:format]}"
        ]
      elsif Gluttonberg.translated?
        # Dialect
        # Default
        [
          "#{filename}.#{opts[:dialect].code}.#{opts[:format]}",
          "#{filename}.#{opts[:format]}"
        ]
      else
        ["#{filename}.#{opts[:format]}"]
      end
      # Loop through them and return the first match
      for candidate in candidates 
        matches = Dir.glob(template_dir / (candidate + ".*"))
        return candidate unless matches.empty?
      end
      # This nil has to be here, otherwise the last evaluated object is 
      # returned, in this case the candidates hash.
      nil
    end
    
    # Returns an array of hashes representing the template files for this 
    # a particular model. The return value will vary depending on the current
    # mode.
    def templates
      # Some cheap memoiziation
      @templates ||= begin
        files = Dir.glob(template_glob)
        # Check to see what mode we are in, that'll define how we parse the file names
        if Gluttonberg.localized? or Gluttonberg.translated?
          # Figure out what regex we need
          matcher, mode = if Gluttonberg.localized?
            [/\/#{filename}.(\w+).([a-z-]+).(\w+).(erb|mab|haml)/, :localized]
          elsif Gluttonberg.translated?
            [/\/#{filename}.([a-z-]+).(\w+).(erb|mab|haml)/, :translated]
          end
          files.inject({}) do |memo, file|
            match = file.match(matcher)
            extract_template_details(memo, mode, match) if match
            memo
          end
        else
          # For the non-localized/dialect mode, just collect the various formats
          files.inject([]) do |memo, file|
            match = file.match(/#{filename}.(\w+).(erb|mab|haml)/)
            memo << match[1] if match
            memo
          end
        end
      end
    end
    
    private
    
    def template_type
      self.class.template_type
    end
    
    # Returns the path to the templates.
    def template_dir
      Gluttonberg.templates_dir(template_type)
    end
    
    # The path to all the templates
    def template_glob
      Gluttonberg.templates_dir(template_type) / "#{filename}.*"
    end
    
    # Extracts a different hash from the matches depending on the current 
    # mode.
    def extract_template_details(memo, mode, match)
      if mode == :localized
        memo[match[1]] ||= {}
        memo[match[1]][match[2]] ||= []
        memo[match[1]][match[2]] << match[3]
      else
        memo[match[1]] ||= []
        memo[match[1]] << match[2]
      end
    end
  end
end