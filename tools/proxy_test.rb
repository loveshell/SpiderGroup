#!/usr/bin/env ruby
# ./proxy_test.rb 120.132.149.76 8080
#
require 'net/http'

proxy_addr = ARGV[0]
proxy_port = ARGV[1].to_i

uri = URI('http://bot.whatismyipaddress.com/')
Net::HTTP::Proxy(proxy_addr, proxy_port).start('bot.whatismyipaddress.com') {|http|
	response = http.get uri.path
	p response.body
}
