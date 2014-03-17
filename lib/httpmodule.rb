require 'net/http'
require 'uri'
require 'open-uri'
require 'guess_html_encoding'
require 'nokogiri'
require 'fileutils'
require 'digest'
require 'pathname'

module HttpModule
  def get_web_content(url, options=nil)
    resp = {:error=>true, :errstring=>'', :code=>999, :url=>url, :html=>nil}

    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url)
      uri = URI(url)
      ip = uri.host
      ip = options[:hostip] if options && options[:hostip]
      resp[:host] = uri.host
      resp[:ip] = ip
      Net::HTTP.start(ip, uri.port) do |http|
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = 10
        http.read_timeout = 10
        request = Net::HTTP::Get.new uri.request_uri
        request['Host'] = uri.host
        request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        request['Accept-Charset'] = 'GBK,utf-8;q=0.7,*;q=0.3'
        request['Accept-Encoding'] = 'gzip,deflate,sdch' unless (ENV['OS'] == 'Windows_NT')  #windows下处理gzip暂时有点问题
        request['Accept-Language'] = 'zh-CN,zh;q=0.8'
        request['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
        request['Referer'] = options[:referer] if options && options[:referer]
        begin
          response = http.request request # Net::HTTPResponse object
          resp[:code] = response.code
          resp[:html] = nil
          if response.header[ 'Content-Encoding' ].eql?( 'gzip' )
            sio = StringIO.new( response.body )
            gz = Zlib::GzipReader.new( sio )
            html = gz.read()
            resp[:html] = html
          else
            resp[:html] = response.body
          end
          resp[:bodysize] = resp[:html].size
          resp[:error] = false

        rescue Timeout::Error => e
          resp[:code] = 999
        rescue =>e
          resp[:code] = 998
        end
      end
    rescue Timeout::Error  => the_error
      resp[:error] = true
      resp[:errstring] = "Timeout::Error of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
    rescue OpenURI::HTTPError => the_error
      resp[:error] = true
      resp[:errstring] = "OpenURI::HTTPError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
    rescue SystemCallError => the_error
      resp[:error] = true
      resp[:errstring] = "SystemCallError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
    rescue SocketError => the_error
      resp[:error] = true
      resp[:errstring] = "SocketError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
    rescue => err
      resp[:error] = true
      resp[:errstring] = "Unknown Exception of : #{url}\n error:#{$!} at:#{$@}\nerror : #{err}"
    end

    resp
  end

  def get_utf8(c)
    encoding = GuessHtmlEncoding.guess(c)
    #puts encoding
    if(encoding)
      if(encoding.to_s != "UTF-8")
        c = c.force_encoding(encoding)
        c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
      end
    else
      c = c.force_encoding('UTF-8')
      if !c.valid_encoding?
        c = c.force_encoding("GB18030")
        if !c.valid_encoding?
          return ''
        end
        c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
      end
    end

    if !c.valid_encoding?
      c = c.force_encoding("GB18030")
      if !c.valid_encoding?
        return ''
      end
      c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
    end

    c
  end

  def get_http(url)
    http = get_web_content url
    http[:utf8html] = get_utf8 http[:html] if http[:html] and http[:html].size > 2
    #puts http[:utf8html]
    http
  end

  def dump_obj_to_file(filename, obj)
    FileUtils.mkdir_p(File.split(filename).first) unless File.exists?(filename)
    File.open(filename, 'w') do |f|
      obj[:time] = Time.now.strftime("%Y-%m-%d %H:%M:%S")  #加入保存时间
      Marshal.dump(obj, f)
    end
  end

  def load_obj_from_file(filename)
    File.open(filename, 'r') do |f|
      return Marshal.load(f)
    end
    nil
  end


  def load_info(url)
    @options ||= {'Version'=>false}
    http_info = nil
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    uri = nil
    begin
      uri = URI(url)
    rescue URI::InvalidURIError
      return nil
    end
    path = File.join(File.dirname(__FILE__), 'results', Digest::MD5.hexdigest(url)+'.tobj')

    #先看文件是否存且时间小于1天
    if File.exists?(path) && !@options['NoCache']
      http_info = load_obj_from_file path

      if @options and @options['Version']
        puts url
        puts path
      end

      #2小时更新一次
      if Time.parse(http_info[:time])+2*60*60 < Time.now
        http_info = nil
      end
    end

    #不存在或者时间超时，则重新获取信息
    if !http_info
      http_info = get_http(url)
      if !http_info[:error]
        dump_obj_to_file path, http_info
      end
    end
    http_info
  end

  def download_img(img_src, refer)
    u = URI.join(refer, URI.encode(img_src))
    abs_img_url = u.to_s
    path = File.join(File.dirname(__FILE__), 'imgs')
    FileUtils.mkdir_p path
    path = File.join(path, Digest::MD5.hexdigest(abs_img_url))
    path += File.extname(u.path) if File.extname(u.path)
    if !File.exists? path
      http = get_web_content img_src, referer: refer
      unless http[:error]
        File.open(path, "wb") do |f|
          f.write(http[:html])
        end
      end
    end
    Pathname.new(path).relative_path_from(Pathname.new(File.dirname(__FILE__))).to_s
  end
end
