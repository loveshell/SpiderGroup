# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'json'

class FastcompanySpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "fastcompany"
    @category = "有趣 资讯 互联网"
    @list_url = "http://www.fastcompany.cn"
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
      doc = Nokogiri::HTML(html[:utf8html])
      #ap doc
      doc.css("article.node").each do |div|
        link = div.css("h1 a")[0]
        link = div.css("h2 a")[0] unless div.css("h1 a")[0]
        cover = div.css("figure img")[0]['src']
        cover = download_img(cover, @url) if @options[:image] && cover
        desc = div.css("div.node-teaser p")[0]
        author = div.css("div.node-submitted a.username")[0]
        
        if author #top news没有信息，这一条先不要
          time = nil
          if div.css("h5.date")[0]
            time = div.css("h5.date")[0].text + " "
            t = div.css("h5.time")[0].text.split(' ')
            ta = t[0].split(':')
            if t[1].include? 'PM'
              ta[0] = (ta[0].to_i + 12).to_s
            end
            time += ta.join(':')
            time += ":00"
          end
          content_list << {:source=>@name, :title=>link.text, :url=>link['href'], :description=>desc.text, :cover=>cover, :author=>author.text.strip, :created_at=>time}
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
      cdiv = doc.css("div.content")[0]
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
      break #只能提取一页
      sleep 1
    end
  end
end

if __FILE__==$0
  FastcompanySpider.new(options: {:page=>1, :image=>1}).fetch {|u|
    ap u
  }
end