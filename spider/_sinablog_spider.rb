if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'json'

class SinablogSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "Sinablog"
    @category = ""
    @list_url = ""
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
      doc.css("div.blog_title_h").each {|d|
        link = d.css("div.blog_title a")[0]
        time = d.css("span.time")[0].text.string_between_markers("(", ")")
        content_list << {:source=>@name, :title=>link.text, :url=>link['href'], :author=>@author, :created_at=>time}
      }

      index = 0
      doc.css("div.content").each {|d|
        content_list[index][:description]=d.text
        index += 1
      }
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
      cdiv = doc.css("div.articalContent")[0]
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
      break
      sleep 1
    end
  end
end
