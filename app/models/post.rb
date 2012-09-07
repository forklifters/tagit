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
    post_tags.find_all_by_user_id(uid).map{ |post_tag| post_tag.tag.name }.join(", ")
  end
  
  def tags_for_user(user) # Select ([post tags] for [this user]) + ([post tags] for [author + followed users] except those this user already has)
    post_tags
      .select('"tags".name, "post_tags".post_id, "post_tags".tag_id, (CASE WHEN "post_tags".user_id = ' + user.id.to_s + ' THEN 1 ELSE 0 END) AS belongs_to_current_user')
      .joins('JOIN "posts" ON "post_tags".post_id = "posts".id')
      .joins('JOIN "tags" ON "post_tags".tag_id = "tags".id')
      .joins('LEFT JOIN "relationships" ON "post_tags".user_id = "relationships".followed_id')
      .where('"post_tags".user_id = ? OR (("post_tags".user_id = "posts".user_id OR "relationships".follower_id = ?) AND "post_tags".tag_id NOT IN (SELECT "post_tags".tag_id FROM "post_tags" WHERE "post_tags".post_id = "posts".id AND "post_tags".user_id = ?))', user.id, user.id, user.id)
      .order('LOWER("tags".name) ASC')
      .group('"tags".name, "post_tags".post_id, "post_tags".tag_id, belongs_to_current_user')
  end
end
