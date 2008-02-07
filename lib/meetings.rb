
require 'rubygems'
require 'yaml'
require 'chronic'
require 'ostruct'


class Meetings

    MEETING_ICAL_URL = "http://www.google.com/calendar/ical/boulderlinux%40gmail.com/public/basic.ics"

    attr_accessor :meetings
    attr_accessor :next_meeting_date
    attr_accessor :prev_meeting_date
    
    class << self
        def speaker_file
            File.expand_path(File.join(File.dirname(__FILE__),"..","data","speakers.yaml"))
        end
    end
    
    def initialize
        @meetings = YAML::load_file(Meetings.speaker_file)
        calc_meeting_dates
    end

    def calc_meeting_dates
        last_month_mtg = Chronic.parse("2nd Thursday of last month")
        this_month_mtg = Chronic.parse("2nd Thursday of this month")
        next_month_mtg = Chronic.parse("2nd Thursday of next month")
        today      = Time.now

        if today > this_month_mtg then
            @next_meeting_date = next_month_mtg
            @prev_meeting_date = this_month_mtg
        else 
            @next_meeting_date = this_month_mtg
            @prev_meeting_date = last_month_mtg
        end
    end

    def meeting_index_of(t)
        r = nil
        t_date = t.strftime("%Y-%m-%d")
        meetings.each_with_index do |m,idx|
            if m['talk']['date'].to_s == t_date then
                return idx
            end
        end
        return nil
    end

    def next_meeting_talk
        meetings[meeting_index_of(next_meeting_date)]['talk']
    end

    def prev_meeting_talk
        meetings[meeting_index_of(prev_meeting_date)]['talk']
    end

    def past_meetings
        past_mtgs = []
        prev_mtg = prev_meeting_date.strftime("%Y-%m-%d")
        meetings.each_with_index do |m,idx|
            if m['talk']['date'].to_s <= prev_mtg then
                past_mtgs << m
            end
        end
        return past_mtgs
    end

        
end

BLUG_MEETINGS = Meetings.new

def next_meeting
    OpenStruct.new(BLUG_MEETINGS.next_meeting_talk)
end    

def prev_meeting
    OpenStruct.new(BLUG_MEETINGS.prev_meeting_talk)
end

def talks
    BLUG_MEETINGS.past_meetings.collect { |m| OpenStruct.new(m['talk']) }
end

if $0 == __FILE__
    o = OpenStruct.new(BLUG_MEETINGS.next_meeting_talk)
    puts o.email
    puts o.date
    
end
