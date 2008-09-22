module Merb
  module GlobalHelpers
    class Cycle
      def initialize(values)
        @values = values
        @cursor = 0
      end

      def current_value
        current = @values[@cursor]
        if @cursor == @values.length - 1
          @cursor = 0
        else
          @cursor += 1
        end
        current
      end
    end
    
    def cycle(name, *values)
      @cycles ||= {}
      @cycles[name] ||= Cycle.new(values)
      @cycles[name].current_value
    end
  end
end
