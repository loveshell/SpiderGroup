# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../website/app/models')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'json'

class DyqqSpider < BaseSpider

  def initialize(*args)
    super(args)
    @name = "dy.qq.com"
    @category = "亲子 儿童 家庭"
    #@list_url = "http://dyapi.inews.qq.com/getSubWebAllNews?id=0&count=100&group=1&t=1400416617623"
    @url = ''
    @replaces = []
    @lastid = 0
  end

  #获取文章列表
  def get_content_url_list
    @logger.debug(self.class.to_s) { " get_content_url_list of "+@url}
    content_list ||= []
    keys = %w|爸爸 妈妈 父母 宝宝 儿子 女儿 老婆 教师 孩子 家长 父亲 母亲 你爸 妻子 辣妈 萌宝 儿童 新娘 小朋友 夫妻|
    #ap @url
    html = load_info @url, 'http://dy.qq.com/all-subscribe.htm' #这里需要设置referer，否则会提示proxy错误
    if !html[:error]
      data = JSON.parse(html[:utf8html])
      if data["ret"] != 0
        @logger.fatal(self.class.to_s) {" get_content_url_list error "+@url}
      else
        data["newslist"].each {|section|
          section.each { |n|
            @lastid = n['id']
            need_add = false
            abstract = n["abstract"]
            title = n["title"]
            keys.each {|k|
              if title.include?(k) || abstract.include?(k)
                need_add = true
                break
              end
            }

            if need_add
              if @options[:image] && n["thumbnails_qqnews"] #是一个数组
                img_url = n["thumbnails_qqnews"][0]
                cover = download_img(img_url, @url)
                @logger.debug "download image from #{img_url}"
              end
              content_list << {:source=>@name, :title=>n["title"], :url=>n["url"],
                               :description=>n["abstract"], :cover=>cover,
                               :created_at=>n["timestamp"], :author=>n["chlname"]}
            end
          }
        }

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

      cdiv = doc.css("div.main")[0]
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
      #@url = get_content_list_url(page)
      @url = "http://dyapi.inews.qq.com/getSubWebAllNews?id=#{@lastid}&count=100&group=1&t=1400416617623"
      #http://dyapi.inews.qq.com/getSubWebAllNews?id=TEC2014051801379100&count=10&group=1&t=1400419477727
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
  DyqqSpider.new(options: {:page=>1, :image=>1} ).fetch {|u|
    ap u
  }
end
