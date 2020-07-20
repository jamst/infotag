class SpiderTarget < ApplicationRecord

  has_one :file_attachment, as: :attachment_entity

  def self.init_migration
    SpiderTarget.create(name:"多维网")
    SpiderTarget.create(name:"网易新闻")
    SpiderTarget.create(name:"世界日报")
    SpiderTarget.create(name:"Youtube")
  end

end