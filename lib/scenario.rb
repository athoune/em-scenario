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

        class AdLib
            include EM::Deferrable
            def initialize(times, &block)
                @times = times
                @cpt = 0
                self.callback(&block)
            end

            def each &block
                @loop = block
                self._oneStep
            end

            def _oneStep
                @loop.call @cpt
                @cpt += 1
            end

            def next
                if @cpt == @times
                    self.succeed
                else
                    self._oneStep
                end
            end

        end
    end
end

def quorum(size, &block)
    EventMachine::Scenario::Quorum.new size, &block
end

def adlib(size, &block)
    EventMachine::Scenario::AdLib.new size, &block
end
