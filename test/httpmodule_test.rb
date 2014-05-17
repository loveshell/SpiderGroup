require 'test/unit'

$:.unshift(File.expand_path(File.dirname(__FILE__)))
.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../')))
.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../website/app/models')))
require 'httpmodule.rb'

class HttpmoduleTest < Test::Unit::TestCase
  include HttpModule

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

  def test_post_img_url_to_webscan
    post_img_url_to_webscan 'http://www.sems.cc/uploads/zpimg/3/5870.jpg'
  end

end

