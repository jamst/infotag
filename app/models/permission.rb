class Permission < ApplicationRecord
  has_and_belongs_to_many :roles, join_table: :roles_permissions

  PERMISSION = {
    'destroy' => 1,
    'update'  => 2,
    'create'  => 3,
    'read'    => 4,
    'manage'  => 5
  }

  def self.compare(a, b)
    -(PERMISSION[a.action].to_i <=> PERMISSION[b.action].to_i)
  end

end
