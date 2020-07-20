class CreateUserTags < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tags do |t|
      t.references "user", comment: "用户"
      t.references "tag", comment: "标签"
      t.integer :hit_count, comment: "点击数量"
    end
  end
end
