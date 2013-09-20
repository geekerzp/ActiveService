class Post < ActiveRecord::Base
  attr_accessible :title, :body
  
  validates :title, :presence => true
  
end
