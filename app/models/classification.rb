class Classification < ApplicationRecord
  has_many :infos
  has_many :videos
  enum status: { disabled: -1, enabled: 0 }
  default_scope -> {where(is_delete: 0)}

  def self.init_migration
    Classification.find_or_create_by(name:"社会",sort_live:10)
    Classification.find_or_create_by(name:"社会-国际",sort_live:11)
    Classification.find_or_create_by(name:"社会-时事",sort_live:12)

    Classification.find_or_create_by(name:"娱乐",sort_live:20)
    Classification.find_or_create_by(name:"娱乐-电影",sort_live:21)
    Classification.find_or_create_by(name:"娱乐-综艺",sort_live:22)
    Classification.find_or_create_by(name:"娱乐-音乐",sort_live:23)
    Classification.find_or_create_by(name:"娱乐-星座运势",sort_live:24)
    Classification.find_or_create_by(name:"娱乐-搞笑",sort_live:25)
    Classification.find_or_create_by(name:"娱乐-漫画",sort_live:26)
    Classification.find_or_create_by(name:"娱乐-百科常识",sort_live:27)

    Classification.find_or_create_by(name:"数码",sort_live:30)
    Classification.find_or_create_by(name:"数码-科技",sort_live:31)

    Classification.find_or_create_by(name:"汽车",sort_live:40)

    Classification.find_or_create_by(name:"时尚",sort_live:50)
    Classification.find_or_create_by(name:"时尚-美妆",sort_live:51)
    Classification.find_or_create_by(name:"时尚-情感",sort_live:52)
    Classification.find_or_create_by(name:"时尚-穿搭",sort_live:53)

    Classification.find_or_create_by(name:"美女",sort_live:60)
    Classification.find_or_create_by(name:"美女-舞蹈",sort_live:61)
    Classification.find_or_create_by(name:"美女-cos",sort_live:62)

    Classification.find_or_create_by(name:"色情",sort_live:70)
    Classification.find_or_create_by(name:"色情-AV",sort_live:70)
    Classification.find_or_create_by(name:"色情-18+",sort_live:70)

    Classification.find_or_create_by(name:"游戏",sort_live:80)
    Classification.find_or_create_by(name:"游戏-漫画",sort_live:81)

    Classification.find_or_create_by(name:"美食",sort_live:90)
    Classification.find_or_create_by(name:"美食-生活",sort_live:91)

    Classification.find_or_create_by(name:"旅游",sort_live:100)
    Classification.find_or_create_by(name:"旅游-摄影",sort_live:101)

    Classification.find_or_create_by(name:"居家",sort_live:110)
    Classification.find_or_create_by(name:"居家-宠物",sort_live:111)
    Classification.find_or_create_by(name:"居家-母婴育儿",sort_live:112)
    Classification.find_or_create_by(name:"居家-健康养生",sort_live:113)
    Classification.find_or_create_by(name:"居家-星座运势",sort_live:114)

    Classification.find_or_create_by(name:"军事",sort_live:120)

    Classification.find_or_create_by(name:"历史",sort_live:130)
    Classification.find_or_create_by(name:"历史-文化",sort_live:131)

    Classification.find_or_create_by(name:"财经",sort_live:140)

    Classification.find_or_create_by(name:"生活",sort_live:150)
    Classification.find_or_create_by(name:"生活-生活日常",sort_live:151)
    Classification.find_or_create_by(name:"生活-vlog",sort_live:152)
  end

  # 清除分类修改导致不一致问题
  def self.crean_diff
    Classification.all.each do |ca|
      $redis.del("classification_#{ca.id}_infos")
      $redis.del("classification_#{ca.id}_videos")
    end
  end

  # up_classification
  def self.up_classification
    Classification.all.each do |ca|
      $redis.sadd("classification_#{ca.id}_infos",Info.where("classification_id = ?", ca.id).ids)
      $redis.sadd("classification_#{ca.id}_videos",Video.where("classification_id = ?", ca.id).ids)
    end
  end

  # 同步爬取设置分类
  def self.up_medial_spider
    MedialSpider.info.each do |medial|
      Info.where("classification_id is null").where("medial_spider_id = ?", medial.id).each do |info|
        info.update(classification_id:medial.classification_id)
      end
    end

    MedialSpider.video.each do |medial|
      Video.where("classification_id is null").where("medial_spider_id = ?", medial.id).each do |video|
        video.update(classification_id:medial.classification_id)
      end
    end
  end


end