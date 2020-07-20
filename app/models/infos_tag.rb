class InfosTag < ApplicationRecord
  has_many :tags
  has_many :infos
end