#!/usr/bin/env ruby

require "ipaddr"
require "json"

class Entry < Struct.new(:time, :service, :ip, keyword_init: true)
  def <=> other
    return self.ip <=> other.ip if self.ip.family == other.ip.family
    return self.ip.family <=> other.ip.family
  end

  def to_json *args
    {
      "time": self.time.strftime("%FT%T%:z"),
      "service": self.service,
      "ip": self.ip.to_s,
    }.to_json(*args)
  end
end

def parse str
  s = str.chomp.split('|')
  raise "Invalid entry: '#{str}'" if s.length != 4
  Entry.new(time: Time.at(s[0].to_i), service: s[1], ip: IPAddr.new(s[3]))
end

def readlines path
  File.open(path).map {|s| parse s}
end

abort "Usage: #{$0} /path/to/blacklist.db" if ARGV.length != 1
list = readlines ARGV[0]
puts JSON.pretty_generate(list.sort)
