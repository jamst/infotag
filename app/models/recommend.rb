class Recommend < ApplicationRecord
  belongs_to :mark
  enum recomment_type: { top: 0, synthesize: 1 }
  default_scope -> {where(is_delete: 0)}
  enum status: { disabled: -1, enabled: 0 }
end