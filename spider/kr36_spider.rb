# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'feedjira'



class Kr36Spider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "36kr"
    @category = "互联网 创业"
    @list_url = "http://www.36kr.com/feed"
    @url = ''
    @replaces = []
  end

  #获取文章列表
  def get_content_url_list
    @logger.debug(self.class.to_s) { " get_content_url_list of "+@url}
    content_list ||= []
    #ap @url
    html = load_info @url
    if !html[:error]
      feed = Feedjira::Feed.parse(html[:utf8html])
      feed.entries.each{|f|
        author = f.author.string_between_markers("(", ")")
        doc = Nokogiri::HTML(f.summary)

        cover = nil
        if doc.css("img")[0]
          cover = doc.css("img")[0]['src']
          cover = download_img(cover, @url) if @options[:image] && cover
        end
        
        content_list << {:source=>@name, :title=>f.title, :url=>f.url, :description=>f.summary, :cover=>cover, :author=>author, :created_at=>f.published}
      
      }
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
      if html[:redirect_url]
        u[:url] = html[:redirect_url]
        return get_content_info u
      end
      doc = Nokogiri::HTML(html[:utf8html])
      cdiv = doc.css("section.article")[0]
      content = cdiv.inner_html

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
  
  #Kr36Spider.new(options: {:page=>2, :image=>1}).get_content_info url:'http://www.36kr.com/p/210763.html'
  Kr36Spider.new(options: {:page=>2, :image=>1}).fetch {|u|
    ap u
  }
end