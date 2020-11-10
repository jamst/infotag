class MedialCache < ApplicationRecord
  enum status: { unapproved: 0, approved: 1 }
  after_save :up_status, if: -> { self.saved_change_to_status? }

  # 更改审核状态
  def up_sttaus
     key = "share_#{self.uuid}"
     data = $redis.get(key)
     data = JSON.parse(data)
     data["status"] = self.status_before_type_cast
     $redis.set(key,data.to_json)
  end

end