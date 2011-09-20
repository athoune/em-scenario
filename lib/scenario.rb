require "eventmachine"

module EventMachine
  # @see http://en.wikipedia.org/wiki/List_of_Latin_phrases
  module Scenario

    class Scenario
      include EM::Deferrable

    end

    class Iterator < Scenario

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

    # from the start
    # Sequences of actions.
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
    class Quorum < Scenario
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
        @times -= 1
        self.succeed(self) if @times == 0
      end
    end

    # As much as enough.
    # You wont lots of parralel workers, but not too much.
    class QuantumSatis
      include EM::Deferrable

      def initialize times, throttle=nil, &block
        @opened = 0
        @finished = 0
        @worker = 0
        @times = times
        @throttle = throttle
        @loop = block
        @debug = false
      end

      def finally &block
        self.callback &block
        if @throttle
          @throttle.times{ call }
        else
          @times.times{ call }
        end
      end

      protected
      def call
        @worker += 1
        @loop.call Proc.new{nextStep}, @opened, @worker
        @opened += 1
        if @debug
          puts "worker: #{@worker} opened: #{@opened} finished: #{@finished}"
        end
      end

      def nextStep
        puts "ending" if @debug
        @finished += 1
        @worker -= 1
        if @finished == @times
          self.succeed
        else
          call if @opened < @times
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

    # Until sick. Act again and again, until criteria
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

alias sequence abinitio

def adnauseum(&block)
  EventMachine::Scenario::AdNauseum.new &block
end

def quantumsatis(times, throttle=nil, &block)
  EventMachine::Scenario::QuantumSatis.new times, throttle, &block
end
