class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username
  
  attr_accessible :name, :username, :email, :password, :password_confirmation
  
  has_secure_password
  
  has_many :posts, dependent: :destroy
  
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  
  has_many :reverse_relationships, :class_name => "Relationship", :foreign_key => "followed_id", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  default_scope order: "users.created_at DESC"
  
  before_save { self.email.downcase! }
  before_save :create_remember_token
  
  validates :name,
    length: { maximum: 60 }
  validates :username,
    presence: true,
		length: { within: 3..30 },
    format: { with: USERNAME_REGEX },
    uniqueness: { case_sensitive: false }
  validates :email,
		presence: true,
    length: { maximum: 254 },
		format: { with: EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
  validates :password,
    presence: true,
    length: { within: 6..40 }
  validates :password_confirmation,
    presence: true
  
  def self.per_page
    10
  end
  
  def stream
    Post.from_user_stream(self).order("created_at DESC")
  end
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end
  
  def self.from_user_stream(user) # Select [posts] from [this user + followed users + tagged posts] that have [tags this user has not blocked]
    Post
      .select('DISTINCT "posts".id, "posts".*')
      .joins('LEFT JOIN "relationships" ON "posts".user_id = "relationships".followed_id')
      .joins('LEFT JOIN "post_tags" ON "posts".id = "post_tags".post_id')
      .joins('LEFT JOIN "user_tags" ON "post_tags".tag_id = "user_tags".tag_id')
      .where('("posts".user_id = ? OR "relationships".follower_id = ? OR "post_tags".user_id = ?) AND "user_tags".tag_id IS NULL', user.id, user.id, user.id)
  end
  
private
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
