class Recommend < ApplicationRecord
  belongs_to :mark
  enum recommend_type: { top: 0, synthesize: 1 }
  default_scope -> {where(is_delete: 0)}
  enum status: { disabled: -1, enabled: 0 }
  after_create :init_sort_live
  after_update :cache_recommend , if: -> { self.saved_change_to_sort_live? }

  RECOMMEND_TYPE = {"top":{"name":"top","value":"全球头条","image_url":"red"},"synthesize":{"name":"synthesize","value":"综合推荐","image_url":"black"}}
  
  # 初始化排序，默认等于ID
  def init_sort_live
    self.update(sort_live:self.id)
  end

  # 更新缓存列表（分别缓存20个）
  def cache_recommend
    if self.top?
      top_recommends = Recommend.top.order(sort_live: :desc).limit(20)
      top_list = []
      top_recommends.each do |_|
         top_list << {recommend_type: "top", recommend_id:_.id, title:_.title, url:_.url, mark_title:_.mark&.title, mark_url: _.mark&.url }
      end
      $redis.set("top_list",top_list)
    else
      synthesize_recommends = Recommend.synthesize.order(sort_live: :desc).limit(20)
      synthesize_list = []
      synthesize_recommends.each do |_|
        synthesize_list << {recommend_type: "synthesize", recommend_id:_.id, title:_.title, url:_.url, mark_title:_.mark&.title, mark_url: _.mark&.url }
      end
      $redis.set("synthesize_list",synthesize_list)
    end
  end

end