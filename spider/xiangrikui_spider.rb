# encoding: utf-8

if __FILE__==$0
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), './')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
end

require 'awesome_print'
require 'base_spider'
require 'json'
require '_sinablog_spider'

class XiangrikuiSpider < SinablogSpider
  def initialize(*args)
    super(*args)
    @list_url = "http://blog.sina.com.cn/u/5041629385"
    @name = "Sinablog_xiangrikui"
    @author = "xiangrikui"
    @category = "教育"
  end
end

if __FILE__==$0
  #加载默认配置
  options = {}
  cfg_file = File.expand_path(File.join(File.dirname(__FILE__), '../config.yml'))
  if File.exist? cfg_file
    cfg = YAML.load_file(cfg_file)
    cfg.each{|k,v|
      options[k.to_sym] = v
    }
  end
  XiangrikuiSpider.new(options: options).fetch {|u|
    ap u
  }
end