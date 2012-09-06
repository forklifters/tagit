class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  
  before_save { |user| user.email = email.downcase }
  
  validates :name, length: { :maximum: 60 }
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
end
