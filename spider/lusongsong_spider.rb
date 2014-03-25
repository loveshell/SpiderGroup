# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'

class LusongsongSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "lusongsong"
    @category = "站长 创业"
    @list_url = ["http://lusongsong.com/default_%i.html","http://lusongsong.com"]
    @url = ''
    @replaces = [{:type=>'replace_between', :from=>'<center>', :to=>'', :from1=>'</center>'}]
  end

  #获取文章列表
  def get_content_url_list
    @logger.debug(self.class.to_s) { " get_content_url_list of "+@url}
    content_list ||= []
    #ap @url
    html = load_info @url
    if !html[:error]
      doc = Nokogiri::HTML(html[:utf8html])
      #ap doc
      doc.css("div.topic-content").each do |div|
        link = div.css("div.post-title-list h2 a")[0]
        if link
          #暂时没有图片
          #if div.css("div.fl img").size>0
          #  cover = div.css("div.fl img")[0]['src']
          #  cover = download_img(cover, @url) if @options[:image] && cover
          #end
          cover = nil
          desc = div.css("div.post-list-info p")[0]
          #time = div.css("div.post-date small")[0].text;
          content = {:source=>@name, :title=>link.text, :url=>link['href'], :description=>desc.text, :cover=>cover}
          content_list << content
          #ap content
        end
      end
      #ap html[:utf8html]
    else
      @logger.fatal(self.class.to_s) {" get_content_url_list error "+@url}
    end
    content_list
  end

  #获取内容正文
  def get_content_info(u)
    #ap u
    @logger.debug(self.class.to_s) {" get_content_info of "+u[:url]}
    html = load_info u[:url]
    if !html[:error]
      doc = Nokogiri::HTML(html[:utf8html])
      u[:author] = '卢松松'

      time_info = doc.css("div.post-title h6")[0].text
      time_arr = time_info.split('  ')
      time = time_arr[0]
      time.gsub!(/[年月]/, '-')
      time.gsub!(/日/, '')
      u[:created_at] = time

      cdiv = doc.css("dd.post-info")[0]
      content = cdiv.inner_html

      #ap content

      u[:content] = replace_by_type(@replaces, content)

      if @options[:image]
        #提取所有图片
        img_list = receive_imgs(cdiv, u[:url])
        u[:content] = replace_by_type(img_list, u[:content])
      end

    else
      @logger.fatal(self.class.to_s) {" get_content_info error "+u[:url]}
    end
    u
  end

  #执行
  def fetch
    @logger.debug(self.class.to_s) {" fetching..."}
    content_list = []
    added = true
    page = 1
    while added && page <= @options[:page]
      @url = get_content_list_url(page)
      added = false
      self.get_content_url_list.each {|u|
        added = true
        self.get_content_info(u)
        if block_given?
          yield u
        end
        sleep 0.5
      }
      page += 1
      sleep 1
    end
  end
end

if __FILE__==$0
  LusongsongSpider.new(options: {:page=>1, :image=>1} ).fetch {|u|
    ap u
  }
end
