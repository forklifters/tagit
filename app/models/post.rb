class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_list
  belongs_to :user
  default_scope order: "posts.created_at DESC"  
  
  validates :title,
    length: { maximum: 200 }
  validates :content,
    presence: true,
    length: { maximum: 10000 }
  validates :user_id,
    presence: true
  
  def self.per_page
    10
  end
  
  def tag_list(uid = user_id)
    "" #post_tags.find_all_by_user_id(uid).map{ |post_tag| post_tag.tag.name }.join(", ")
  end
end

