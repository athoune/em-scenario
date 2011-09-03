require "eventmachine"

module EventMachine
    module Scenario

        class Sequence
        end

        class Quorum
            include EM::Deferrable
            def initialize(times, &block)
                @times = times
                self.callback(&block)
            end

            def next(*arg)
                @times -= 1
                self.succeed(*arg) if @times == 0
            end
        end
    end
end

def quorum(size, &block)
    EventMachine::Scenario::Quorum.new size, &block
end

