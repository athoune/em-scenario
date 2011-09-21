require "eventmachine"

module EventMachine
  module Scenario

    # Just like with em-http-request
    class Multi
      include EM::Deferrable

      def initialize
        @actions = 0
      end

      def add deferable
        @actions += 1
        deferable.callback do
          @actions -= 1
          self.succeed if @actions == 0
        end
      end

    end

  end
end
