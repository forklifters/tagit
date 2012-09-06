class Post < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
  default_scope order: 'posts.created_at DESC'  
  
  # validates :title,
  #   :length => { :maximum => 200 }
  validates :content,
    :presence => true,
    :length => { :maximum => 10000 }
  validates :user_id,
    :presence => true
end
