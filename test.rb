require 'feedjira'
require 'pp'

feed = Feedjira::Feed.fetch_and_parse('http://www.36kr.com/feed')
pp feed

