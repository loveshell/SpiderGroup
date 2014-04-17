#!/usr/bin/env ruby
# ./upload_img_test.rb ./img/abc.jpg
#
require "net/http"
require "uri"
require "pp"
require "json"
require "sixarm_ruby_magic_number_type"


def post_img_data_to_webscan(img_data, img_path)
	# Token used to terminate the file in the post body. Make sure it is not
	# present in the file you're uploading.
	boundary = "upload_img_test_AaB03x"

	uri = URI.parse("http://webscan.360.cn/timgurl/jy")

	ext = img_data.magic_number_type
	puts ext

	post_body = []
	post_body << "--#{boundary}\r\n"
	post_body << "Content-Disposition: form-data; name=\"upfile\"; filename=\"#{File.basename(img_path)}\"\r\n"
	post_body << "Content-Type: image/#{ext}\r\n"
	post_body << "\r\n"
	post_body << img_data
	post_body << "\r\n--#{boundary}--\r\n"

	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Post.new(uri.request_uri)
	request.body = post_body.join
	request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

	response = http.request(request)
	data = JSON.parse(response.body)
	if data['error'] && data['url']
		data['url']
	else
		puts data
		nil
	end
end

def post_img_to_webscan(img_path)

	if img_path.length < 1 then
		puts "error : need input a image file to send"
		exit
	end

	img_data = File.read(img_path)
	post_img_data_to_webscan(img_data, img_path)
end

def post_img_url_to_webscan(img_url, referer=nil)
	#http://webscan.360.cn/timgurl/url    post  参数名:url
	uri = URI.parse("http://webscan.360.cn/timgurl/url")
	response = Net::HTTP.post_form(uri, 'url' => "http://proxy.fofa.so/image.php?ref=#{referer}&img=#{img_url}")
	data = JSON.parse(response.body)
	if data['error'] && data['url']
		data['url']
	else
		puts data
		nil
	end
end

@file = ARGV[0]
if @file.include? 'http://'
	@referer = ARGV[1]
	puts post_img_url_to_webscan(@file, ARGV[1])
else
	puts post_img_to_webscan(@file)
end