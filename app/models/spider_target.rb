class SpiderTarget < ApplicationRecord

  has_one :file_attachment, as: :attachment_entity
  has_many :medial_spiders
  has_many :infos
  has_many :videos
  default_scope -> {where(is_delete: 0)}
  enum status: { disabled: -1, enabled: 0 }

  def self.init_migration
    SpiderTarget.create(name:"多维网")
    SpiderTarget.create(name:"网易新闻")
    SpiderTarget.create(name:"世界日报")
    SpiderTarget.create(name:"Youtube")
  end

  # 更新图片地址
  def up_logo_url
    SpiderTarget.all.each do |target|
      gsub_url = target.logo_url.gsub("sz6.je2ci9.com/infoflow_pics","sz6.dayomall.com:54600")
      target.update(logo_url:gsub_url)
    end
  end
  
end