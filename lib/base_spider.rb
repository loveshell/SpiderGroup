require 'httpmodule'
require 'replaceparser'
require 'logger'

class BaseSpider
  include HttpModule
  include ReplaceParser
  attr_reader :url, :name, :logger, :options, :list_url, :category

  def initialize(*args)
    @logger ||= Logger.new(STDOUT)
    #@logger.level = Logger::WARN

    @logger = args[0][0][:logger] if args && args[0] && args[0][0] && args[0][0][:logger]
    @options = args[0][0][:options] if args && args[0] && args[0][0] && args[0][0][:options]
  end

  # 如果是数组，那么[1]表示第一页
  def get_content_list_url(i)
    if @list_url.is_a? Array
      if i==1
        return @list_url[1]
      else
        return @list_url[0] % i
      end
    else
      return @list_url % i
    end
  end

end
