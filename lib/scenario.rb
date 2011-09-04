require "eventmachine"

module EventMachine
    # @see http://en.wikipedia.org/wiki/List_of_Latin_phrases
    module Scenario

        # from the start
        class AbInitio
            include EM::Deferrable

            def initialize &block
                @actions = []
                self.callback &block
            end

            def then &block
                d = EM::DefaultDeferrable.new
                d.callback(&block)
                @actions << d
            end

            def next *arg
                if @actions.length > 0
                    @actions.pop.succeed(*arg)
                else
                    self.succeed *arg
                end
            end

            def invoke *arg
                @actions.reverse!
                self.next *arg
            end
        end

        #Trigger when a quota of actions is done
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

        # Repeat sequentially an action
        class AdLib
            include EM::Deferrable
            def initialize &block
                @cpt = 0
                self.callback(&block)
            end

            def repeat times, &block
                @times = times
                @loop = block
                self._oneStep
            end

            def _oneStep
                @loop.call @cpt
                @cpt += 1
            end

            def next *arg
                if @cpt == @times
                    self.succeed *arg
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

def adlib(&block)
    EventMachine::Scenario::AdLib.new &block
end

def abinitio(&block)
    EventMachine::Scenario::AbInitio.new &block
end
