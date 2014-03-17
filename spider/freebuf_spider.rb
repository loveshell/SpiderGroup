if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'

class FreebufSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "Freebuf"
    @category = "安全"
    @list_url = "http://www.freebuf.com/page/%i" #http://www.freebuf.com/page/2
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
      doc.css("div.news_inner").each do |div|
        link = div.css("dt a")[0]
        cover = div.css("div.newspic01 img")[0]['src']
        cover = download_img(cover, @url) if @options[:image] && cover
        desc = div.css("dd.text")[0]
        author = div.css("dd")[1].css("a")[1]
        time = div.css("dd")[1].children.select { |t|
          "Nokogiri::XML::Text" == t.class.to_s && t.text.include?("共")
        }[0].text;
        time["共"] = ''
        content_list << {:source=>@name, :title=>link.text, :url=>link['href'], :description=>desc.text, :cover=>cover, :author=>author.text, :created_at=>time.strip!}
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
      content = doc.css("div.news_text")[0].inner_html

      u[:content] = replace_by_type(@replaces, content)
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
  FreebufSpider.new(:logger => Logger.new('freebuf.log') ).fetch {|u|
    #ap u
  }
end