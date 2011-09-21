require "eventmachine"

module EventMachine
  module Scenario

    class Timer

      include EM::Deferrable

      def initialize timer, &block
        self.callback &block
        @id = EM.add_timer(timer) do
            self.succeed
        end
      end

      def cancel
        EM.cancel_timer @id
      end

    end

  end
end
