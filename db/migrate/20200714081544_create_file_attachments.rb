class CreateFileAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :file_attachments do |t|
      t.string :attachment_entity_type, limit: 64
      t.integer :attachment_entity_id
      t.string :path, comment: '文件路径'
      t.string :name, comment: '文件名'
      t.string :content_type, comment: '文件类型'
      t.integer :file_size, comment: '文件大小'
      t.integer :created_by, comment: '上传人'
      t.integer :is_delete, default: 0
      t.timestamps
    end
  end
end
