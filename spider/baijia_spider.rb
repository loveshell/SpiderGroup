if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'json'

class BaijiaSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "BaiduBaijia_Internet"
    @category = "自媒体,互联网"
    @list_url = "http://baijia.baidu.com/ajax/labellatestarticle?page=%i&pagesize=20&labelid=2&prevarticalid=6912"
    @url = ''
    @replaces = [{type:'replace_between', from:'<div class="l-main-inner-ad">', to:'', from1:'</div>'},
                 {type:'string_replace', from:'          ', to:' ', repead:true}
    ]
  end

  #获取文章列表
  def get_content_url_list
    @logger.debug(self.class.to_s) { " get_content_url_list of "+@url}
    content_list ||= []
    #ap @url
    html = load_info @url
    if !html[:error]
      data = JSON.parse(html[:utf8html])
      if data["errno"] != 0
        @logger.fatal(self.class.to_s) {" get_content_url_list error "+@url}
      else
        data["data"]["list"].each {|n|
          cover = download_img(n["m_image_url"], @url) if @options[:image] && n["m_image_url"]
          content_list << {:source=>@name, :title=>n["m_title"], :url=>n["m_display_url"],
                           :description=>n["m_summary"], :cover=>n["m_image_url"],
                           :created_at=>n["m_create_time"]}
        }

      end
    else
      @logger.fatal(self.class.to_s) {" get_content_url_list error "+@url+": "+html[:errstring]}
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
      content = doc.css("div.article-detail")[0].inner_html
      author = doc.css("div.article-author-time a")[0].text

      u[:content] = replace_by_type(@replaces, content)
      u[:author] = author
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
      @url = @list_url % page
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
  BaijiaSpider.new( ).fetch {|u|
    ap u
  }
end