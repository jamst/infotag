class UserTagDetail < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  belongs_to :from_entity, polymorphic: true
  
end