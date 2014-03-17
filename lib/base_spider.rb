require 'httpmodule'
require 'replaceparser'
require 'logger'

class BaseSpider
  include HttpModule
  include ReplaceParser
  attr_reader :url, :name, :logger, :options

  def initialize(*args)
    @logger ||= Logger.new(STDOUT)
    #@logger.level = Logger::WARN

    @logger = args[0][0][:logger] if args && args[0] && args[0][0] && args[0][0][:logger]
    @options = args[0][0][:options] if args && args[0] && args[0][0] && args[0][0][:options]
    @options ||= {page:1}
  end

end