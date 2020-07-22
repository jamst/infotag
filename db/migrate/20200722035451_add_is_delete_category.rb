class AddIsDeleteCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_delete, :integer, default: 0, comment: "是否删除"
    add_column :tags, :is_delete, :integer, default: 0, comment: "是否删除"
    add_column :spider_targets, :is_delete, :integer, default: 0, comment: "是否删除"
  end
end
