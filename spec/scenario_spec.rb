#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario::Quorum do
    it "wait for n actions to be finished" do
        EM.run do
            quorum(5) do |nextStep|
                5.times do |i|
                    EM.add_timer(Random.rand(0.1)) do
                        nextStep.call
                    end
                end
            end.finally do
                assert true
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
                assert true
                assert [0,1,2,3,4] == stack
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
