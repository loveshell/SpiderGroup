# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'

class IheimaSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "iheima"
    @category = "互联网 创业"
    @list_url = ["http://new.iheima.com/%i.html","http://new.iheima.com/"]
    @url = ''
    @replaces = [{:type=>'replace_to_end', :from=>'如文中未特别声明转载请注明出自', :to=>''}]
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
      doc.css("div.txs_cont").each do |div|
        link = div.css("h3 a")[0]
        if link
          if div.css("div.fl img").size>0
            cover = div.css("div.fl img")[0]['src']
            cover = download_img(cover, @url) if @options[:image] && cover
          end
          desc = div.css("p.txs_Contfr")[0]
          time = div.css("span.fl span")[0].text;
          content = {:source=>@name, :title=>link.text, :url=>link['href'], :description=>desc.text, :cover=>cover, :created_at=>time}
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
      u[:author] = doc.css("span.fl span")[2].text.strip!
      u[:author]['来源：'] = '' if u[:author].include? "来源："
      u[:author]['投稿者：'] = '' if u[:author].include? "投稿者："

      cdiv = doc.css("div.txs_Content")[0]
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
  IheimaSpider.new(options: {:page=>1, :image=>1} ).fetch {|u|
    ap u
  }
end
