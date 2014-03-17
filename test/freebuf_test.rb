require 'test/unit'

$:.unshift(File.expand_path(File.dirname(__FILE__)))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
  .unshift(File.expand_path(File.join(File.dirname(__FILE__), '../spider')))
require 'freebuf_spider.rb'

class FreebufTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_replace_by_type
    fs = FreebufSpider.new
    str = "aaabbbccc"

    replaces = [{:type=>"replace_to_end", :from=>'bbb', :to=>''}]
    assert_equal("aaa", fs.replace_by_type(replaces, str))

    replaces = [{:type=>"replace_to_position", :from=>'bbb', :to=>''}]
    assert_equal("bbbccc", fs.replace_by_type(replaces, str))

    replaces = [{:type=>"string_replace", :from=>'bbb', :to=>'ddd'}]
    assert_equal("aaadddccc", fs.replace_by_type(replaces, str))

    replaces = [{:type=>"replace_between", :from=>'ab', :from1=>'bc', :to=>'ddd'}]
    assert_equal("aadddcc", fs.replace_by_type(replaces, str))

    str = "aaa.*?bbb[]+~!ccc"
    replaces = [{:type=>"string_replace", :from=>'.*?bbb[]+~!', :to=>'ddd'}]
    assert_equal("aaadddccc", fs.replace_by_type(replaces, str))
  end

  def test_download_img
    fs = FreebufSpider.new
    fs.download_img 'http://f.hiphotos.baidu.com/news/crop%3D39%2C24%2C468%2C281%3Bw%3D638/sign=fcde87b85e6034a83dade2c1f6207078/ca1349540923dd5433b5a9d1d309b3de9d824840.jpg', 'http://xiepeng.baijia.baidu.com/article/7355'
  end

end

