class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password
  has_many :posts, dependent: :destroy
  
  default_scope order: 'users.created_at DESC'  
  
  before_save { self.email.downcase! }
  before_save :create_remember_token
  
  validates :name,
    length: { maximum: 60 }
  # validates :username,
  #   presence: true,
	# 	length: { within: 3..30 },
  #   format: { with: USERNAME_REGEX },
  #   uniqueness: { case_sensitive: false }
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
  
private
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
