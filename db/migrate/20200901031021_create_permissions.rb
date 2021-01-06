class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.string :controller, comment: '控制器名称'
      t.string :action, comment: '方法名称'
      t.timestamps
    end

    create_table :roles_permissions, id: false do |t|
      t.references :role
      t.references :permission
    end

    add_index :roles_permissions, [:role_id, :permission_id]
  end
end
