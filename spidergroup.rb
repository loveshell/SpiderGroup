#!/usr/bin/env ruby
require 'optparse'
require 'yaml'

#将当前根目录作为库加载目录
$:.unshift(File.expand_path(File.dirname(__FILE__))).unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'spider')))
require 'db_manager'

#解析参数
class OptsConsole
  #
  # Return a hash describing the options.
  #
  def self.parse(args)
    options = { :page=>1,:image=>0, :cachetime=>7200, :log_level=>0 }

    #加载默认配置
    cfg_file = File.expand_path(File.join(File.dirname(__FILE__), 'config.yml'))
    if File.exist? cfg_file
      cfg = YAML.load_file(cfg_file)
      cfg.each{|k,v|
        options[k.to_sym] = v
      }
      #options.each{|k,v|
      #  puts k,v
      #}
    end

    opts_ = OptionParser.new do |opts|
      opts.banner = "Spider Group By LubyRuffy"
      opts.separator "Usage : #{$0} [OPTIONS] <SOURCE1[,SOURCE2...]>"

      opts.separator ""
      opts.separator "Common options:"

      # Boolean switches
      opts.on("-l", "--list", "Show spider source list") do
        puts "===============All source==============="
        Dir["./spider/*_spider.rb"].each do |file|
          f = File.split(file)[1]
          f = f[0..f.index("_spider")-1]
          puts f
        end
        puts "===============All source==============="
        exit
      end

      opts.on("-p", "--page <page>", "Spider page count, DEFAULT=1") do |p|
        options[:page] = p.to_i
      end

      opts.on("-e", "--level <level>", "Log level, DEFAULT=0 (0 error; 1 info; 2 debug)") do |p|
        options[:log_level] = p.to_i
      end

      opts.on("-i", "--image <0|1>", "Whether download image and replace img src, DEFAULT=0") do |p|
        options[:image] = p.to_i
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    begin
      opts_.parse!(args)
    rescue OptionParser::InvalidOption
      puts "Invalid option, try -h for usage"
      exit
    end

    options
  end
end

@options = OptsConsole.parse(ARGV)
@logger ||= Logger.new(STDOUT)
@logger.level = Logger::ERROR
@logger.level = case @options[:log_level]
                  when 0 then Logger::ERROR
                  when 1 then Logger::INFO
                  when 2 then Logger::DEBUG
                  else Logger::ERROR
                end
#@logger = Logger.new('operation.log')
DBManager.new(@options)

def exec_spider(f)
  if File.exists? (f)
    puts "exec_spider "+f
    require f

    #动态创建类
    f = File.split(f)[1]
    f = f[0..f.index("_spider")-1]
    classname = f.capitalize + "Spider"
    spider = Kernel.const_get(classname).new(logger: @logger, options: @options)

    #执行
    spider.fetch {|u|
      begin
        if Content.where(url: u[:url]).exists?
          @logger.info "content has already exists : "+u[:url]
        else
          Content.create(u)
        end
      rescue =>e
        @logger.fatal "create content error "+u.to_s+" : "+e.to_s
      end
    }
  end
end

ARGV.each do |f|
  case f
    when 'all'
      Dir["./spider/*_spider.rb"].each do |file|
        exec_spider file
      end
  else
    exec_spider "./spider/"+f+"_spider.rb"
  end
end
