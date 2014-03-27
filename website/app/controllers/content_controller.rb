# encoding: utf-8

$tags = {
"bigbrother" => %w|腾讯 百度 新浪 华为 阿里 牌照 金融 微信 来往 微软 谷歌 京东 美团 特斯拉 中国移动 中国联通 电信 大众点评 酒仙网 银联 IBM HP 余额宝 央行 土豆 1号店 苹果 英特尔 4G 中兴 九城 YY 小米 红米 MIUI Google 海尔 微博 携程 赶集 58同城 金钱豹 支付宝 银行 Facebook 星巴克 联想 HTC 蓝港在线 Azure 网易 新东方 优酷 youku LTE 亚马逊 500彩票网 网龙 淘宝 艺龙 如家 汉庭 Line KaKaoTalk WhatsApp 百合网 陌陌 步步高 天弘基金|,
"people" => %w|王小川 周鸿祎 俞敏洪 柳传志 陈年 刘强东 马云 朱骏 孙正义 李彦宏 姚劲波 傅盛 雷军 张朝阳 王峰 朱新礼 杨守彬 丁磊 马化腾 徐小平 鬼脚七 扎克伯格 乔布斯 唐岩|,
"security" => %w|黑客 漏洞 攻击 DDoS WAF 防火墙 渗透测试 freebuf keenteam ASLR nmap 安全扫描 安全协议 网络战 入侵 木马 后门 反射攻击 安全工程师 XSS 安全事件 网络劫持 安全问题 破解 APT 斯诺登 NSE Nmap 网络安全 网站安全 Security 病毒 安全 篡改 侵入 网络犯罪 网络间谍 黑阔 Shellcode 恶意软件代码 身份欺诈 盗刷 恶意软件 穷举 诈骗 盗窃 取证 Dos攻击 OWASP 隐私泄露 泄密门 恶意程序 感染 0day 执行任意代码 内存破坏 系统崩溃 金山毒霸 信息安全 AdwCleaner 监控 杀毒 白帽 泄露门 安全事故 信用卡泄露 NSA Shotgiant 监视 writeup 伪装 隐私 信用卡门 漏洞分析 监听 嗅探 密码泄露|  ,
"relax" => %w|姚晨 谢娜 李代沫 汪峰 明星 影视 娱乐 林依轮 满文军 爱情公寓 米老鼠|,
"startup" => %w|创始人 创业者 创业 融资 大姨吗 无印良品 电商 商业模式 收购 破产 投资人 股权 投资 创业家 暴利|,
"code" => %w|编程 编码 程序员 极客 云计算 大数据 可穿戴 软件 Erlang Linux 代码 BUG bug 图灵 Java java python ruby Ruby Python JAVA PHP php CSDN|,
"yunying" => %w|粉丝 品牌 渠道 营销 扩张 复制 传播 个性化 差异 玩法 分销 运营 促销 口碑 梦想 参与感 积分体系 会员俱乐部 转型|,
"cool" => %w|创意 创造力 非常酷 太有才 泡妞 Oculus 天才 有趣|,
"webmaster" => %w|建站 站长 SEO 网站加速 网站安全 网赚 wordpress dedecms 卢松松|,
"other" => %w|马来西亚 马航 航空 广电 互联网思维 互联网 颠覆 革命 疑云 发布 高端 产品定位 自救 企业 实战 公众号 好文 小马哥 鲶鱼 股东 复兴 技术 专家 无家可归 DNS 智能手机 智能手表 物联网 智能电视 智能家居 智能硬件 汽车 世界杯 电视 危机 死亡 监管 体制 搅局 建班子 定战略 带队伍 研究 众筹 泼点冷水 泼冷水 股份 百亿 10亿 黑马 iPhone iPad Mac 大屏 谍照 靠谱 自媒体 联盟 意欲何为 开发产品 研发产品 CEO 恋情 硬件 逃生 体验 畅想 红海 手机 增长 消失 淘点点 商家 商铺 通信领域 专利 市场份额 格局 新媒体 基金 盈利 BAT 在线旅游 战略合作 消费者 O2O SocialCRM 市值 20亿 推荐 上市 手游 调查数据 劲霸男装 移动生活 诚信 第三方支付 软肋 夜店 小女生 二维码 绞杀 快捷支付 支票 里程碑 网购 赚钱 千元机 市场化 华尔街 沙龙 媒体见面会 开放 下载 纠集 大会 90后 70后 80后 工行 IPO 野心 总裁 零售 百货 逆袭 估值 信用卡 整合 少林寺 试验品 课堂 案例 演讲 分发渠道 游戏平台 开房 身份证 cvv CVV 移动支付 MH370 速递 学大  TOP10 陨落 餐饮 360智键 猪猪侠 信任 趋势 社交媒体 智能路由器 教育 无人机 选人 用人 留人 法则 深度 风云人物 年营收|,
}
class ContentController < ApplicationController

private
	def get_category(title, desc)
		cats = {}
		$tags.each {|k,v|
			tag_values = []
			v.each {|w|
				if (title && title.include?(w)) || (desc && desc.include?(w))
					tag_values << w
				end
			}

			cats[k] = tag_values if tag_values.size>0
		}
		cats
	end

	def get_contents(sql=nil)
		contents = []
		if sql
			contents = Content.where(sql).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC') 
  		else
  			contents = Content.paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
  		end 
  		contents.each { |c|
  			c.cat = get_category(c.title, c.description)
  		}
  		contents
	end
	
	def render_tag(tagname, if_or=true)
		sql = nil
		@tag_array = nil
		if tagname.respond_to? "map"
			@tag_array = tagname
		else
			@tag_array = $tags[tagname]
		end

		if if_or
			sql = @tag_array.map{|x| "title like '%#{x}%' or description like '%#{x}%'"}.join(' or ')
		else
			sql = @tag_array.map{|x| "title not like '%#{x}%' and description not like '%#{x}%'"}.join(' and ')
		end

  		@contents = get_contents(sql)
  		render(:action => 'index')    
	end

	def render_source(source, if_or=true)
  		@contents = get_contents(:source=>source)
  		render(:action => 'index')    
	end

  def countSubstrings str, subStr
    return str.scan(subStr).length
  end
	
public

  def all
  	day = Time.now.strftime("%Y-%m-%d 00:00:00")
  	puts day
  	@contents = get_contents("created_at>='#{day}' and id not in (SELECT content_id from ipvotes where ip='#{request.remote_ip}')")
  	@hot_artical = Content.find_by_sql("select * from contents join (select content_id as id, sum(vote) as vote from ipvotes where created_at>='#{day}' group by content_id ORDER BY vote desc limit 10) t on contents.id=t.id where vote>0")
  	@vote = true

    words = Content.find_by_sql("select title,description from contents where created_at>='#{day}'")
    str = ''
    words.each {|c|
      str += c.title
      str += ":"
      str += c.description
      str += "|"
    }

    @hot_word = {}
    $tags.each {|k,vals|
      vals.each {|v|
        @hot_word[v] = countSubstrings(str, v)
      }
    }
    @hot_word.sort_by{|k,v| v}.reverse

  	render(:action => 'index')    
  end

  def index
  	@contents = get_contents()
  end

  def bigbrother
  	render_tag params[:action]  
  end

  def people
  	render_tag params[:action]   
  end

  def security
  	render_tag params[:action] 
  end

  def code
  	render_tag params[:action] 
  end

  def cool
  	render_tag params[:action] 
  end

  def webmaster
  	render_tag params[:action] 
  end

  def newbie
  	all_array = []
  	$tags.each{|k,v| all_array += v}
  	#puts all_array
  	render_tag all_array,false  
  end
#################source#####################
  def Freebuf
  	render_source params[:action] 
  end

  def iheima
  	render_source params[:action] 
  end

  def lusongsong
  	render_source params[:action] 
  end

  def vaikan
  	render_source params[:action] 
  end
#################
  def vote
  	ip = request.remote_ip
  	if !Ipvote.where(ip: ip, content_id: params[:content_id]).exists?
  		Ipvote.create({ip: ip, content_id: params[:content_id], vote: params[:vote], created_at: Time.now })
  	end

  	if request.referer
  		redirect_to request.referer
  	else
	  redirect_to :action => 'index'
	end
  end
##################
  def view
  	@content = Content.find(params[:id])
  end

  def word
  	render_tag [params[:w]]
  end

end
