class RemoveRelationshipsAndPostTagsTimestamps < ActiveRecord::Migration
  def up
    remove_column :relationships, :created_at
    remove_column :relationships, :updated_at
    remove_column :post_tags, :created_at
    remove_column :post_tags, :updated_at
  end

  def down
    add_column(:relationships, :created_at, :datetime)
    add_column(:relationships, :updated_at, :datetime)
    add_column(:post_tags, :created_at, :datetime)
    add_column(:post_tags, :updated_at, :datetime)
  end
end
