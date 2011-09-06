#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario::Quorum do
    it "wait for n actions to be finished" do
        EM.run do
            q = quorum
            5.times do |i|
                q.add do |finished|
                    EM.add_timer(Random.rand(0.1)) do
                        finished.call
                    end
                end
            end
            q.when do
                assert true
                EM.stop
            end
        end
    end

    it "act 5 times" do
        EM.run do
            stack = []
            adlib do
                assert true
                assert [0,1,2,3,4] == stack
                EM.stop
            end.repeat 5 do |nextStep, i|
                stack << i
                EM.add_timer(Random.rand(0.1)) do
                    nextStep.call
                end
            end
        end
    end

    it "do something after other thing" do
        EM.run do
            txt = ""
            abinitio do
                assert "HELLO WORLD" == txt
                EM.stop
            end.then do |nextStep|
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
            end.invoke
        end
    end
end
