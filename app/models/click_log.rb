class ClickLog < ApplicationRecord
  # mongodb 文档的大小限制是16MB
  # 指定存储方式为mongodb
  include Mongoid::Document
  # Mongoid::Timestamps 提供了 created_at 和 updated_at field
  include Mongoid::Timestamps
  # Mongoid 提供了一个简单的机制来将他们转换成正确合适的类型，通过field定义，值得注意的是，转换出错并不会影响数据的创建

  field :session_id, type: String # 浏览器session
  field :user_id, type: String # 用户帐号设备uuid
  field :device_uuid, type: String # 
  field :medial_type, type: String # 资讯类型
  field :medial_id, type: String # 资讯ID
  field :tag_ids, type: String # 标签
  field :uuid, type: String # 设备id

  field :vpn_key, type: String # 产品uuid
  field :vpn_version, type: String # 产品版本名
  field :vpn_version_number, type: String # 产品版本号
  field :vpn_channel, type: String # 渠道商

  field :request_ip, type: String # 用户IP
  field :api_domain, type: String # 用户连接后台域名
  field :country, type: String # 国家
  field :province, type: String # 省份
  field :city, type: String # 城市

  def tag_list
    Tag.where(id:tag_ids&.split(",")).pluck(:name)
  end

  def user_tag_list
    user_tag_ids = $redis.smembers("users_#{user_id}")
    Tag.where(id:user_tag_ids&.split(",")).pluck(:name)
  end

  def medial
    if medial_type.present? && medial_id.present?
      @medial = medial_type.camelize.constantize.find_by(id:medial_id)
    end
    @medial
  end

end