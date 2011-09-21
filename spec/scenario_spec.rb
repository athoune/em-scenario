#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario::Quorum do
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

  it "do the same thing with an iterator" do
    EM.run do
      EM::Iterator.new(0..4, 50).map(proc { |i, iter|
        EM.add_timer(Random.rand(0.1)) do
          iter.return i
        end
      }, proc{ |responses|
        assert [0, 1, 2, 3, 4] == responses.sort
        EM.stop
      })
    end
  end

  it "iterate with scenario iterator" do
    EM.run do
      EM::Scenario::Iterator.new(0..4) do |i, iter|
        EM.add_timer(Random.rand(0.1)) do
          iter.return i
        end
      end.finally do |responses|
        assert [0, 1, 2, 3, 4] == responses.sort
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

  it "chain different scenario" do
    EM.run do
      one = []
      two = []
      quorum(2) do |nextStep|
        2.times do |i|
          one << i
          EM.add_timer(Random.rand(0.1)) do
            nextStep.call
          end
        end
      end.finally do
        quorum(3) do |nextStep|
          3.times do |i|
            two << i
            EM.add_timer(Random.rand(0.1)) do
              nextStep.call
            end
          end
        end.finally do
          assert [0,1,2] == two.sort
          assert [0,1] == one.sort
          EM.stop
        end
      end
    end
  end

  it "chain with sequence" do
    EM.run do
      stack = []
      EM::Scenario::Sequence.new do
        EM::Scenario::Timer.new(0.4) do
          stack << 1
        end
      end.then do
        EM::Scenario::Timer.new(0.3) do
          stack << 2
        end
      end.then do |iter|
        EM::Scenario::Timer.new(0.2) do
          stack << 3
          iter.return 42 #you can return values for the next step
        end
      end.then do |iter, n|
        assert n == 42 # and retrieve it
        EM::Scenario::Timer.new(0.1) do
          stack << 4
        end
      end.then do
        assert (1..4).to_a == stack
        EM.stop
      end
    end
  end

  it "uses the multi" do
    EM.run do
      m = EM::Scenario::Multi.new
      stack = []
      m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
        stack << 1
      end)
      m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
        stack << 2
      end)
      m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
        stack << 3
      end)
      m.callback do
        assert [1,2,3] == stack.sort
        EM.stop
      end
    end
  end

end
