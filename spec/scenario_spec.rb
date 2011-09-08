#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario::Quorum do
    it "wait for n actions to be finished" do
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

end
