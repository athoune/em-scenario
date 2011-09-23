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
        self
      end

    end

    #
    # Syntax sugar for creating a Multi
    #
    def Scenario.join(*deferrables, &block)
      m = Multi.new
      deferrables.each do |deferrable|
        m.add deferrable
      end
      m.callback &block
      m
    end

  end
end
