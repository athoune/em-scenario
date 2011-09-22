require "eventmachine"

EM.run do

#
# Wrap Apple Motion Sensor.
# http://osxbook.com/software/sms/amstracker/
#
class Ams < EM::Connection
  def receive_data data
    puts data.split(' ').map{ |a| a.to_f}.inspect
  end
end

  EM.popen('./AMSTracker -u 0.1 -s', Ams)
end
