class Role < ApplicationRecord
  has_and_belongs_to_many :employees, :join_table => :employees_roles
  has_and_belongs_to_many :permissions, join_table: :roles_permissions
end
