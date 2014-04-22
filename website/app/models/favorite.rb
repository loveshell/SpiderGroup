class Favorite < ActiveRecord::Base
  def content
    Content.find(self.content_id)
  end
end
