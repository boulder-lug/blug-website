#!/usr/bin/env ruby

require 'time'
require 'date'
require 'rubygems'
require 'yaml'
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

  def second_thursday_of(date = Date.today)
    this_month = Date.new(date.year, date.month, 1)
    thursday_count = (this_month.wday == 4) ? 1 : 0
    while thursday_count < 2 
      this_month += 1
      thursday_count += 1 if this_month.wday == 4
    end
    return this_month
  end


  def calc_meeting_dates
    today = Date.today

    this_month_mtg = second_thursday_of(today)
    last_month_mtg = second_thursday_of(today << 1)
    next_month_mtg = second_thursday_of(today >> 1)

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

  def future_phrase(date)
    case Date.today - date
    when 0
          "today"
    when 1
          "tomorrow"
    when 7
          "next week"
    else
          "coming up"
    end
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

The #{next_meeting_date.strftime("%B")} Boulder Linux User Group meeting is #{future_phrase(next_meeting_date)}.

   Talk : #{next_meeting_talk['title']}

Speaker : #{next_meeting_talk['speaker'].gsub(/<(.|\n)*?>/,'')}

   When : 7:15 p.m. on #{next_meeting_date.strftime("%a, %b %d, %Y")} 

  Where : Applied Trust, 1033 Walnut St, Bulder, CO 80302

          Applied Trust is on Walnut Street in downtown Boulder. It is
          the door just west of Amante Coffee.

    Map : http://lug.boulder.co.us/meetings.html

Parking : Parking on the street is free after 7pm and there are 2 public
          garages on Walnut at $1.25/hour and bike parking on the sidewalk
          in front of the office.

    Bus : Less than 2 blocks from Broadway which is served by the Skip busses.
          Less than 4 blocks from the Boulder Transit Center which serves
          almost all routes.

EOM

if next_meeting_talk['desc'] then
  msg += <<SUMMARY

Summary of '#{next_meeting_talk['title']}'
#{'-' * (next_meeting_talk['title'].length + 13)}

#{next_meeting_talk['desc']}
SUMMARY
end

msg += <<FOOTER

Pre meeting food
----------------

Food will be available at the meeting location, so please show up around 6:45 pm
and join us for a bite to eat. We'll start the meeting about 7:15.


--
Boulder Linux User Group
http://lug.boulder.co.us
FOOTER
  end

end

BLUG_MEETINGS = Meetings.new
FROM_EMAIL    = "boulderlinux@gmail.com"
FROM_NAME     = "Boulder Linux"
TO_EMAIL      = %w[ announce@lug.boulder.co.us lug@lug.boulder.co.us ]

def next_meeting
  OpenStruct.new(BLUG_MEETINGS.next_meeting_talk)
end    

def prev_meeting
  OpenStruct.new(BLUG_MEETINGS.prev_meeting_talk)
end

def talks
  BLUG_MEETINGS.past_meetings.collect { |m| OpenStruct.new(m['talk']) }
end

def days_until_next_meeting
  BLUG_MEETINGS.next_meeting_date - Date.today
end

if $0 == __FILE__
  raw_msg = BLUG_MEETINGS.next_meeting_email("#{FROM_NAME} <#{FROM_EMAIL}>", TO_EMAIL)
  #raw_msg = BLUG_MEETINGS.next_meeting_email("#{FROM_NAME} <#{FROM_EMAIL}>", "jeremy@collectiveintellect.com")
  if ARGV.first == "--send-email" then
    if [1, 7].include?(days_until_next_meeting) or ARGV[1] == "--force" then
      require 'net/smtp'
      Net::SMTP.start("localhost", 25) do |smtp|
        smtp.send_message(raw_msg, FROM_EMAIL, *TO_EMAIL)
      end
    end
  else
    puts raw_msg
  end
end
