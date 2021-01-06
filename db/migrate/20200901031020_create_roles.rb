class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table(:roles) do |t|
      t.string :name
      t.string :name_cn
      t.timestamps
    end

    create_table(:employees_roles, :id => false) do |t|
      t.references :employee
      t.references :role
    end

    add_index(:roles, :name)
    add_index(:employees_roles, [ :employee_id, :role_id ])
  end
end
