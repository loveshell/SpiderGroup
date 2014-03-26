# encoding: utf-8

$tags = {
"bigbrother" => %w|腾讯 百度 新浪 华为 阿里 牌照 金融 微信 来往 微软 谷歌 京东 美团 特斯拉 移动 联通 电信 大众点评 酒仙网 银联 IBM HP 余额宝 央行 土豆 1号店 苹果 英特尔 4G 中兴 九城 YY 小米 红米 MIUI Google 海尔 微博 携程 赶集 58同城 金钱豹 支付宝 银行 Facebook|,
"people" => %w|王小川 周鸿祎 俞敏洪 柳传志 陈年 刘强东 马云 朱骏 孙正义 李彦宏 姚劲波 傅盛 雷军 张朝阳|,
"security" => %w|黑客 漏洞 攻击 DDoS WAF 防火墙 渗透测试 freebuf keenteam ASLR nmap 安全扫描 安全协议 网络战 入侵 木马 后门 反射攻击 安全工程师 XSS 安全事件 网络劫持 安全问题 破解 APT 斯诺登 NSE Nmap 网络安全 网站安全 Security 病毒 安全 篡改 侵入 网络犯罪 网络间谍 黑阔 Shellcode 恶意软件代码 身份欺诈 盗刷 恶意软件|,
"relax" => %w|姚晨 谢娜 李代沫|,
"startup" => %w|创始人 创业 融资 大姨吗 无印良品 电商|,
"code" => %w|编程 编码 程序员 极客 云计算 大数据 可穿戴 智能电视 智能家居 智能硬件|,
"cool" => %w|创意 创造力 非常酷 太有才 泡妞 Oculus|,
"webmaster" => %w|建站 站长 SEO 网站加速 网站安全 网赚 wordpress dedecms|,
}
class ContentController < ApplicationController

private
	def get_category(title, desc)
		cats = []
		$tags.each {|k,v|
			v.each {|w|
				if (title && title.include?(w)) || (desc && desc.include?(w))
					cats << k
					break
				end
			}
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
	
public
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

  def view
  	@content = Content.find(params[:id])
  end

end
