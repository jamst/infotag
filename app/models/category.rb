class Category < ApplicationRecord
  has_many :infos
  has_many :videos
  enum status: { disabled: -1, enabled: 0 }

  def self.init_migration
    Category.create(name:"推荐")
    Category.create(name:"国际")
    Category.create(name:"美食")
    Category.create(name:"旅游")
    Category.create(name:"科技")
    Category.create(name:"娱乐")
  end

end