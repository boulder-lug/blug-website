
require 'rubygems'
require 'yaml'
require 'chronic'
require 'ostruct'


class Meetings

    MEETING_ICAL_URL = "http://www.google.com/calendar/ical/boulderlinux%40gmail.com/public/basic.ics"
    NEXT_MEETING     = "2nd thursday of next month"

    attr_accessor :meetings
    
    class << self
        def speaker_file
            File.expand_path(File.join(File.dirname(__FILE__),"..","data","speakers.yaml"))
        end
    end
    
    def initialize
        @meetings = YAML::load_file(Meetings.speaker_file)
        @next_meeting_date = Chronic.parse(NEXT_MEETING).strftime("%Y-%m-%d")
    end
    
end

def next_meeting
    OpenStruct.new(Meetings.new.meetings.first['talk'])
end    

def prev_meeting
    OpenStruct.new(Meetings.new.meetings[1]['talk'])
end

def talks
    Meetings.new.meetings.collect { |m| OpenStruct.new(m['talk']) }
end

if $0 == __FILE__
    o = OpenStruct.new(Meetings.new.meetings.first['talk'])
    puts o.email
    puts o.date
    
end
