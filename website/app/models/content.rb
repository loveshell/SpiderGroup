class Content < ActiveRecord::Base
	attr_accessor :cat, :favorite, :like
  acts_as_commentable

end
