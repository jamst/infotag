class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, comment: "名称"
      t.integer :status, default: 1, comment: "状态"
      t.text :connection_tags, comment: "关联"
      t.timestamps
    end
    add_index :tags, :name
    add_index :tags, :status
  end
end
