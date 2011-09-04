#!/usr/bin/env ruby

require "minitest/autorun"
require "scenario"

describe EventMachine::Scenario::Quorum do
    it "wait for n actions to be finished" do
        EM.run do
            q = quorum(5) do
                assert true
                EM.stop
            end
            5.times do |i|
                EM.add_timer(Random.rand(0.1)) do
                    q.next
                end
            end
        end
    end

    it "act 5 times" do
        EM.run do
            stack = []
            a  = adlib do
                assert true
                assert [0,1,2,3,4] == stack
                EM.stop
            end
            a.repeat 5 do |i|
                stack << i
                EM.add_timer(Random.rand(0.1)) do
                    a.next
                end
             end
        end
    end

end
