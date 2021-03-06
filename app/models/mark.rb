class Mark < ApplicationRecord
  has_many :recomments
  default_scope -> {where(is_delete: 0)}
  enum status: { disabled: -1, enabled: 0 }
  
end