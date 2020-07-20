class CreateUserTagDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tag_details do |t|
      t.references "user", comment: "用户"
      t.references "tag", comment: "标签"
      t.string :from_entity_type, comment: "来源模型"
      t.integer :form_entity_id, comment: "来源id"
      t.text :from_url, comment: "来源url"
    end
  end
end
