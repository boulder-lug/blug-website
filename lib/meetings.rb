#!/usr/bin/env ruby

require 'time'
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

    def next_meeting_email(from, to)
        to = to.join(', ') if to.kind_of?(Array)
        mtg_date = next_meeting_date.strftime("%Y-%m-%d")
        msg = <<EOM
From: #{from}
To: #{to}
Subject: BLUG Meeting Announcement #{mtg_date}
Date: #{Time.now.rfc2822}
    
    http://lug.boulder.co.us/calendar.html

The next Boulder Linux User Group meeting is coming up.

   Talk : #{next_meeting_talk['title']}

Speaker : #{next_meeting_talk['speaker']}

   When : 7 p.m. on #{next_meeting_date.strftime("%a, %b %d, %Y")} 

  Where : Aztec Networks, 2477 55th St, Suite 202, Boulder, CO.

          Aztec Networks is on 55th between Arapahoe and Perl, just
          north of the Humane Society.  There's plenty of parking, and
          the 206 and 208 busses stop across the street.

    Map : http://lug.boulder.co.us/meetings.html

Please join us informally for a bite to eat at Panera Bread before the
meeting, around 5:30 P.M.  Panera is in the 29th street mall, east of
Highway 36/28th street near Walnut.


--
Boulder Linux User Group
http://lug.boulder.co.us
EOM
    end

end

BLUG_MEETINGS = Meetings.new
FROM_EMAIL    = "Boulder Linux <boulderlinux@gmail.com>"
TO_EMAIL      = [ '"BLUG Announce Mailing List" <announce@lug.boulder.co.us>', 
                  '"BLUG Mailing List" <lug@lug.boulder.co.us>' ]

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
    #raw_msg = BLUG_MEETINGS.next_meeting_email(FROM_EMAIL, TO_EMAIL)
    raw_msg = BLUG_MEETINGS.newxt_meeting_email(FROM_EMAIL, "jeremy@collectiveintellect.com")
    require 'net/smtp'
    Net::SMTP.start("localhost", 25) do |smtp|
        smtp.send_message(raw_msg, FROM_EMAIL, "jeremy@collectiveintellect.com")
    end
end
