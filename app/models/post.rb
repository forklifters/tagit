class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_list
  
  belongs_to :user
  has_many :post_tags, :class_name => 'PostTag', :foreign_key => 'post_id', :dependent => :destroy
  has_many :tags, :through => :post_tags, :source => :tag
  
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
  
  def tag_with_list(list, user, destroy_old = true)
    return if list.blank?
  
    post_tags.find_all_by_user_id(user.id).each(&:destroy) if (destroy_old)
    
    tag_names = list.split(/,\s*/)
    new_tags = tag_names.map{ |tag_name| Tag.find_or_create_by_name(tag_name) }
    post_tags.push(new_tags.map{ |new_tag| PostTag.find_or_create_by_post_id_and_tag_id_and_user_id(id, new_tag.id, user.id) })
  end
  
  def tag!(tag, user)
    post_tags.create!(:tag_id => tag.id, :user_id => user.id)
  end
  
  def untag!(tag, user)
    post_tags.find_by_tag_id_and_user_id(tag, user).destroy
  end
  
  def is_tagged?(tag, user)
    post_tags.find_by_tag_id_and_user_id(tag, user)
  end
  
  def tags_for_author
      post_tags
        .select('"tags".name, "post_tags".post_id, "post_tags".tag_id, 0 AS belongs_to_current_user')
        .joins('JOIN "posts" ON "post_tags".post_id = "posts".id')
        .joins('JOIN "tags" ON "post_tags".tag_id = "tags".id')
        .where('"post_tags".user_id = "posts".user_id')
        .order('LOWER("tags".name) ASC')
        .group('"tags".name, "post_tags".post_id, "post_tags".tag_id, belongs_to_current_user')
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
  
  def is_collapsed_by(user)
    user.settings.collapse_posts == "true" || (!user.settings.collapsed_posts.nil? && user.settings.collapsed_posts.include?(id))
  end
  
  def self.from_followed_users(user)      
    Post.where(:user_id => user.following_ids)
  end
  
  def self.from_user_stream(user) # Select [posts] from [this user + followed users + tagged posts] that have [tags this user has not blocked]
    Post
      .select('DISTINCT "posts".id, "posts".*')
      .joins('LEFT JOIN "relationships" ON "posts".user_id = "relationships".followed_id')
      .joins('LEFT JOIN "post_tags" ON "posts".id = "post_tags".post_id')
      .where('("posts".user_id = ? OR "relationships".follower_id = ? OR "post_tags".user_id = ?)', user.id, user.id, user.id)
      # .joins('LEFT JOIN "user_tags" ON "post_tags".tag_id = "user_tags".tag_id')
      # .where('("posts".user_id = ? OR "relationships".follower_id = ? OR "post_tags".user_id = ?) AND "user_tags".tag_id IS NULL', user.id, user.id, user.id)
  end
end
