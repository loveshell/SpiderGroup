# encoding: utf-8

#!/usr/bin/env ruby
# encoding: utf-8
# 分析一个文章是否足够有趣、震撼、酷
#
require 'net/http'
#将当前根目录作为库加载目录
$:.unshift(File.expand_path(File.dirname(__FILE__))).unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../')))
require 'db_manager'
require 'yaml'

@cool_word = %w|想象力 不可思议 搞怪 神奇 捧腹 趣味十足 充满张力 奇葩 称奇 疯狂 震惊 绝妙 震撼 创意 爆红 疯转  惊声 叫绝 小趣闻 鲜为人知 令人神往 奇迹 心驰神往 魅力 谜团 最笨蛋 最囧 最离奇 诡异 惊天 咋舌 眼泪 感人 回忆 非同寻常 迅速走红 有爱 极品 哭笑不得 迷人 沉醉 难以置信 奇观 神秘 最期待 传奇色彩 精彩 世界上最 打动 窒息 感动 温馨 瞬间 灵感 可爱 萌 惊呆 肃然起敬 大开眼界 惊人 独一无二 疯迷 狂人 惊得我下巴都掉了 最难忘镜头 简直不敢相信 戏剧性 伟大 不该错过 瞠目结舌|
#三大 四大 五大 六大 七大 八大 九大 十大

#加载默认配置
@options = {}
cfg_file = File.expand_path(File.join(File.dirname(__FILE__), '../config.yml'))
if File.exist? cfg_file
  cfg = YAML.load_file(cfg_file)
  cfg.each{|k,v|
    @options[k.to_sym] = v
  }
end
@options[:dbfile] = '.'+@options[:dbfile] 
DBManager.new(@options)

Content.all.each {|c|
	info = c.title+':'+c.description
	keys = []
	@cool_word.each {|w|
		if info.include? w
			keys << w
		end
	}
	puts c.title+" -> "+keys.to_s if keys.size>0 and !c.title.include? "8点1氪"
}
