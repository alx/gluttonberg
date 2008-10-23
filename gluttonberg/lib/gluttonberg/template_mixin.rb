module Gluttonberg
  module TemplateMixin
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
          files.inject([]) do |memo, file|
            unless file.scan(/\/#{filename}.\w+.(erb|mab|haml)/).empty?
              @has_default = true
            else
              match = file.match(matcher)
              memo << extract_template_details(mode, match)
            end
            memo
          end
        else
          # For the non-localized/dialect mode, just collect the various formats
          files.inject([]) do |memo, file|
            memo << file.match(/#{filename}.(\w+).(erb|mab|haml)/)[1]
            memo
          end
        end
      end
    end
    
    # Returns true if a valid default template has been found.
    def has_default?
      !@has_default.nil? and @has_default == true
    end
    
    private
    
    # A Stub. This should be replaced with a version which returns the path
    # to the templates.
    def template_glob
    end
    
    # Extracts a different hash from the matches depending on the current 
    # mode.
    def extract_template_details(mode, match)
      if mode == :localized
        {:locale => match[1], :dialect => match[2], :format => match[3]}
      else
        {:dialect => match[2], :format => match[3]}
      end
    end
    
  end
end