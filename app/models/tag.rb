class Tag < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged
  
  attr_accessible :name
  
  has_many :post_tags, :class_name => "PostTag", :foreign_key => "tag_id", :dependent => :destroy
  has_many :posts, :through => :post_tags, :source => :post
  
  has_many :user_tags, :class_name => "UserTag", :foreign_key => "tag_id", :dependent => :destroy
  
  validates :name,
    :presence => true,
    :length => { :maximum => 30 },
    :uniqueness => { :case_sensitive => false }
    
  def count
    PostTag.where(:tag_id => id).length
  end
  
  def self.find_or_create_by_name(*args)
    options = args.extract_options!
    options[:name] = args[0] if args[0].is_a?(String)
    case_sensitive = options.delete(:case_sensitive)
    conditions = case_sensitive ? ['name = ?', options[:name]] : ['LOWER(name) = ?', options[:name].downcase] 
    first(:conditions => conditions) || create(options)
  end
end
