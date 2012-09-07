class PostTag < ActiveRecord::Base
  attr_accessible :post_id, :tag_id, :user_id
  
  belongs_to :post
  belongs_to :tag
  belongs_to :user
  
  validates :post_id,
    :presence => true
  validates :tag_id,
    :presence => true
  validates :user_id,
    :presence => true
end
