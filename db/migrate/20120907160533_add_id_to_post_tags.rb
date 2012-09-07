class AddIdToPostTags < ActiveRecord::Migration
  def change
    add_column :post_tags, :id, :primary_key
  end
end
