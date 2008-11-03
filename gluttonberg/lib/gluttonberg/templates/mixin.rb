module Gluttonberg
  module Templates
    module Mixin

      def self.included(klass)
        klass.class_eval do
          include InstanceMethods
          extend ClassMethods

          class << klass; attr_accessor :template_dir_name end
        end
      end

      module InstanceMethods
        # Instance version of template for. Calls out to the class method with
        # the filename of this particular template.
        def template_for(opts = {})
          self.class.template_for(filename, opts)
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

        # A string to be used when globbing the templates.
        def template_glob
          Gluttonberg.templates_dir(self.class.template_dir_name) / "#{filename}.*"
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

      module ClassMethods

        def set_template_dir(dir_name)
          @template_dir_name = dir_name
        end

        # Returns the path to the templates.
        def template_dir
          Gluttonberg.templates_dir(template_dir_name)
        end

        # Returns a specific template, or alternately returns a default.
        def template_for(filename, opts = {})
          # A bunch of potential matches in order of preference.
          candidates = if Gluttonberg.localized?
            # Locale and dialect
            # Locale only
            # Default
            [
              "#{filename}.#{opts[:locale].slug}.#{opts[:dialect].code}",
              "#{filename}.#{opts[:locale].slug}",
              "#{filename}"
            ]
          elsif Gluttonberg.translated?
            # Dialect
            # Default
            [
              "#{filename}.#{opts[:dialect].code}",
              "#{filename}"
            ]
          else
            ["#{filename}.*"]
          end
          # Loop through them and return the first match
          for candidate in candidates 
            path = template_dir / candidate + ".*"
            matches = Dir.glob(path)
            return candidate unless matches.empty?
          end
          # This nil has to be here, otherwise the last evaluated object is 
          # returned, in this case the candidates hash.
          nil
        end
      end

    end
  end  
end
