#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario do

  def rand_timer(max, &block)
    EM::Scenario::Timer.new(Random.rand(max)) { block.call }
  end

  it "do the same thing with an iterator" do
    EM.run do
      EM::Iterator.new(0..4, 50).map(proc { |i, iter|
        rand_timer(0.1) do
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
        rand_timer(0.1) do
          iter.return i
        end
      end.finally do |responses|
        assert [0, 1, 2, 3, 4] == responses.sort
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
          rand_timer(0.1) do
            nextStep.call
          end
        end
      end.finally do
        quorum(3) do |nextStep|
          3.times do |i|
            two << i
            rand_timer(0.1) do
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
        rand_timer(0.4) do
          stack << 1
        end
      end.then do
        rand_timer(0.3) do
          stack << 2
        end
      end.then do |iter|
        rand_timer(0.2) do
          stack << 3
          iter.return 42 #you can return values for the next step
        end
      end.then do |iter, n|
        assert n == 42 # and retrieve it
        rand_timer(0.1) do
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

  it "mix multi and sequence" do
    EM.run do
      stack = []
      EM::Scenario::Sequence.new do
        m = EM::Scenario::Multi.new
        10.times do
          m.add(rand_timer(0.5) { stack << 0 })
        end
        m
      end.then do
        m = EM::Scenario::Multi.new
        10.times do
          m.add(rand_timer(0.5) { stack << 1 })
        end
        m
      end.then do
        rand_timer(0.5) do
          assert [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] == stack
          EM.stop
        end
      end
    end
  end

end
