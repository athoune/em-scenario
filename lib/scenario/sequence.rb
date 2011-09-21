require "eventmachine"

module EventMachine
  module Scenario

    class Sequence
      include EM::Deferrable

      # block must return a deferrable
      def initialize &block
        @action = []
        @bag = Bag.new
        block.call(@bag).callback do
          @action[0].call
        end
        self
      end

      def then &block
        size = @action.size + 1
        @bag.incr
        @action << proc {
          defer = block.call(@bag, *@bag[size+1])
          if size < @action.length
            defer.callback do
              @action[size].call
            end
          end
        }
       self
      end

    end

    private
    class Bag

      def initialize
        @datas = []
        @poz = 0
      end

      def incr
        @poz +=1
      end

      def return *data
        @datas[@poz] = data
      end

      def [] poz
        @datas[poz]
      end

    end

  end
end
