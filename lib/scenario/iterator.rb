require "eventmachine"

module EventMachine
  module Scenario

    class Iterator
      include EM::Deferrable

      def initialize array, workers=10, &block
        @datas = array
        @action = block
        @workers = workers
      end

      def finally &block
        EM::Iterator.new(@datas, @workers).map(
            @action, block
        )
      end
    end

  end
end
