#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario do

  it "waits for n actions to be finished" do
    EM.run do
      stack = []
      quorum(5) do |nextStep|
        5.times do |i|
          stack << i
          EM.add_timer(Random.rand(0.1)) do
            nextStep.call
          end
        end
      end.finally do
        assert [0, 1, 2, 3, 4] == stack.sort
        EM.stop
      end
    end
  end

  it "waits for actions and a time out" do
    EM.run do
      stack = []
      q = quorum(20) do |nextStep|
        20.times do |i|
          EM.add_timer(Random.rand(0.1)) do
            stack << i
            nextStep.call
          end
        end
      end
      q.errback do |*args|
        assert [:too_late] == args
        assert stack.length < 20
        EM.stop
      end
      q.timeout 0.1, :too_late
      q.finally do
        assert false, 'too late should happens'
      end
    end
  end

  it "try until success" do
    EM.run do
      cpt = 0
      adnauseum do |nextStep|
        EM.add_timer(Random.rand(0.1)) do
          cpt += 1
          nextStep.call
        end
      end.until do
        cpt > 5
      end.finally do
        assert true
        EM.stop
      end
    end
  end

  it "act 5 times" do
    EM.run do
      stack = []
      adlib(5) do |nextStep, i|
        stack << i
        EM.add_timer(Random.rand(0.1)) do
          nextStep.call
        end
      end.finally do
        assert [0,1,2,3,4] == stack
        EM.stop
      end
    end
  end

  it "act not so fast" do
    EM.run do
      stack = []
      quantumsatis(5, 2) do |nextStep, i, workers|
        assert workers <= 2
        EM.add_timer(Random.rand(0.1)) do
          stack << i
          nextStep.call
        end
      end.finally do
        assert (0..4).to_a == stack.sort
        EM.stop
      end
    end
  end

  it "do something after other thing" do
    EM.run do
      txt = ""
      abinitio do |sequence|
        sequence.then do |nextStep|
          EM.add_timer(Random.rand(0.1)) do
            txt = "Hello "
            nextStep.call
          end
        end.then do |nextStep|
          EM.add_timer(Random.rand(0.1)) do
            txt += "World"
            nextStep.call
          end
        end.then do |nextStep|
          EM.add_timer(Random.rand(0.1)) do
            txt.upcase!
            nextStep.call
          end
        end
      end.finally do
        assert "HELLO WORLD" == txt
        EM.stop
      end
    end
  end



end
