require 'lib/meetings'
module BlugHelpers
  def next_meeting
    OpenStruct.new(BLUG_MEETINGS.next_meeting_talk)
  end    

  def prev_meeting
    OpenStruct.new(BLUG_MEETINGS.prev_meeting_talk)
  end

  def talks
    BLUG_MEETINGS.past_meetings.collect { |m| OpenStruct.new(m['talk']) }
  end
end
