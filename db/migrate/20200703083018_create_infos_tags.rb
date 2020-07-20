class CreateInfosTags < ActiveRecord::Migration[5.2]
  def change
    create_table :infos_tags do |t|
      t.references "info", comment: "咨讯"
      t.references "tag", comment: "标签"
    end
  end
end
