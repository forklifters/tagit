USERNAME_REGEX_BASE = /[a-z0-9]+[-\w]+[a-z0-9]+/
USERNAME_REGEX = /^#{USERNAME_REGEX_BASE}$/i # Starts and ends with a letter or a digit, has letters, digits, hyphens or underscores in between
AT_USERNAME_REGEX = /@(#{USERNAME_REGEX_BASE})/i
EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

module ExternalType
  Twitter = 1
end