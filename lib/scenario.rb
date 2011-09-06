require "eventmachine"

module EventMachine
    # @see http://en.wikipedia.org/wiki/List_of_Latin_phrases
    module Scenario

        # from the start
        class AbInitio
            include EM::Deferrable

            def initialize &block
                @actions = AbInitioActions.new
                block.call @actions
                self
            end

            def nextStep
                if @actions.actions.length > 0
                  @actions.actions.pop.succeed(Proc.new { nextStep })
                else
                    self.succeed
                end
            end

            def finally &block
                self.callback &block
                @actions.actions.reverse!
                self.nextStep
            end
        end

        class AbInitioActions
            attr_accessor :actions
            def initialize
                @actions = []
            end

            def then &block
                d = EM::DefaultDeferrable.new
                d.callback(&block)
                @actions << d
                self
            end

       end

        #Trigger when a quota of actions is done
        class Quorum
            include EM::Deferrable

            def initialize times, &block
                @times = times
                @loop = block
                self
            end

            def finally &block
                self.callback(&block)
                @loop.call( Proc.new {nextStep} )
            end

            protected
            def nextStep
                if @times == 0
                    self.succeed
                else
                    @times -= 1
                    @loop.call( Proc.new {nextStep} )
                end
            end
        end

        # Repeat sequentially an action
        class AdLib
            include EM::Deferrable

            def initialize times, &block
                @cpt = 0
                @times = times
                @loop = block
                self
            end

            def finally &block
                self.callback(&block)
                self.nextStep
            end

            def nextStep
                if @cpt == @times
                    self.succeed
                else
                    @loop.call( Proc.new {nextStep}, @cpt)
                    @cpt += 1
                end
            end
        end

        class AdNauseum
            include EM::Deferrable

            def initialize &block
                @loop = block
                self
            end

            def until &block
                @criteria = block
                self
            end

            def finally &block
                self.callback &block
                @loop.call( Proc.new { nextStep })
                self
            end

            def nextStep
                if @criteria.call
                    self.succeed
                else
                    @loop.call( Proc.new { nextStep })
                end
            end
        end
    end
end

def quorum(times, &block)
    EventMachine::Scenario::Quorum.new times, &block
end

def adlib(times, &block)
    EventMachine::Scenario::AdLib.new times, &block
end

def abinitio(&block)
    EventMachine::Scenario::AbInitio.new &block
end

def adnauseum(&block)
    EventMachine::Scenario::AdNauseum.new &block
end
