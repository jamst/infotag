class MedialSpider < ApplicationRecord

  enum status: { disabled: -1, enabled: 0 }
  enum need_approve: { unneed: 0, need: 1 }
  enum medial_type: { info: 0, video: 1 }
  default_scope -> {where(is_delete: 0)}
  belongs_to :spider_target
  belongs_to :category
  belongs_to :classification
  has_many :videos, -> {where(medial_type: "video")}, class_name: 'MedialSpider'
  has_many :infos, -> {where(medial_type: "video")}, class_name: 'MedialSpider'
  after_update :srem_category, if: -> { self.saved_change_to_category_id? }

  include FileHandle

  IMPORT_COLUMNS = {
    'spider_target': 0,
    'url': 1 ,    
    'category': 2,
    'medial_type': 3,
    'classification': 4,
    'tags_str': 5, 
    'need_approve': 6,
    'web_site': 7 
  }

  EXPORT_COLUMN = {
    'spider_target|name': 0,
    'url': 1 ,    
    'category|name': 2,
    'medial_type': 3,
    'classification|name': 4,
    'tags_str': 5, 
    'need_approve': 6,
    'web_site': 7 
  }

  # 导入
  def self.save_from_hash(hash)
      medial_spiders = []
      message = "导入成功！"
      web_site = MedialSpider.find_by(url: hash[:url])
      # if web_site.present?
      #   medial_spiders << hash
      #   message = "#{hash[:url]} 该地址已存在！"
      # else
        spider_target = SpiderTarget.find_by(name:hash[:spider_target])
        spider_target_id = spider_target&.id || 4
        category_id = Category.find_by(name:hash[:category])&.id
        need_approve = hash[:need_approve] == "自动审核" ? 0 : 1
        medial_type = hash[:medial_type] == "视频" ? 1 : 0
        classification_id = Classification.find_by(name:hash[:classification])&.id
        medial_spider = MedialSpider.find_or_initialize_by(url: hash[:url])
        medial_spider.assign_attributes(category_id: category_id,
                                               medial_type: medial_type,
                                         spider_target_id: spider_target_id,
                                              need_approve: need_approve ,
                                              classification_id: classification_id,
                                              web_site: hash[:web_site])
        medial_spider.save
      # end
      return medial_spiders , message
  end

  # 统计爬取条数
  def count_size
    if medial_type == "video"
      Video.where(medial_spider_id:self.id).count
    else
      Info.where(medial_spider_id:self.id).count
    end
  end

  # 更改classification同时联动变更资讯明细类型
  def srem_category
    if self.medial_type == "info"
      infos = Info.where(medial_spider_id:self.id)
      infos.each do |info|
        $redis.srem("category_#{info.category_id}_infos", info.id)
        $redis.sadd("category_#{self.category_id}_infos", info.id)
      end
      infos.update_all(category_id:self.category_id)
    else
      videos = Video.where(medial_spider_id:self.id)
      videos.each do |video|
        $redis.srem("category_#{video.category_id}_videos", video.id)
        $redis.sadd("category_#{self.category_id}_videos", video.id)
      end
      videos.update_all(category_id:self.category_id)
    end
  end
  
  # 初始化资讯设置
  def self.init_info_spider
    links_list=[
        {spider_target_id: 1, "url":'https://www.dwnews.com/zone/10000117/中国',"category_id":2,"web_site":"中国"},
        {spider_target_id: 1, "url":'https://www.dwnews.com/zone/10000118/全球',"category_id":2,"web_site":"全球"},
        {spider_target_id: 2, "url":'https://news.163.com/',"category_id":6,"web_site":"网易娱乐"},
        {spider_target_id: 2, "url":'https://travel.163.com/',"category_id":4,"web_site":"网易旅行"},
        {spider_target_id: 2, "url":'https://tech.163.com/',"category_id":5,"web_site":"网易科技"},
        {spider_target_id: 3, "url":'https://www.worldjournal.com/category/美食/?variant=zh-cn',"category_id":3,"web_site":"美食"}
      ]
    links_list.each do |spid|
      MedialSpider.find_or_create_by(spider_target_id: spid[:spider_target_id], medial_type:0, url:spid[:url], web_site:spid[:web_site], category_id:spid[:category_id])
    end
  end

  # 初始化视频设置
  def self.init_video_spider
    links_list=[
        {"category_id": "推荐", "id": 1, "url": 'https://www.youtube.com/c/心靈觉醒/videos'},
        {"category_id": "推荐", "id": 2, "url": 'https://www.youtube.com/c/看电影了没/videos'},
        {"category_id": "推荐", "id": 3, "url": 'https://www.youtube.com/user/netss7/videos'},
        {"category_id": "推荐", "id": 4, "url": 'https://www.youtube.com/c/秘史趣聞/videos'},
        {"category_id": "娱乐", "id": 5, "url": 'https://www.youtube.com/channel/UCCbYWuRvD2q_3qSla1gNHtg/videos'},
        {"category_id": "推荐", "id": 6, "url": 'https://www.youtube.com/channel/UCulFhrW_YCwkq_BP16C82mA/videos'},
        {"category_id": "推荐", "id": 7, "url": 'https://www.youtube.com/channel/UCA0o60mhG0v2Eha8wSL3_Jw/videos'},
        {"category_id": "国际", "id": 8, "url": 'https://www.youtube.com/channel/UCMiUxG01G2LhQHNSzgSfY5w/videos'},
        {"category_id": "推荐", "id": 9, "url": 'https://www.youtube.com/channel/UCT6k1jUhPL_d9GnCGNegi8A/videos'},
        {"category_id": "推荐", "id": 10, "url": 'https://www.youtube.com/channel/UC4gENL0K5J_gTODGW0dN3fQ/videos'},
        {"category_id": "娱乐", "id": 11, "url": 'https://www.youtube.com/channel/UCCkZHI7t5fEbiGAcbKE_38w/videos'},
        {"category_id": "推荐", "id": 12, "url": 'https://www.youtube.com/channel/UCd8q0LbxDc6G9jn7Yz5F1lw/videos'},
        {"category_id": "国际", "id": 13, "url": 'https://www.youtube.com/channel/UCgHnxx3v_FM3D6Jmbh82zFQ/videos'},
        {"category_id": "国际", "id": 14, "url": 'https://www.youtube.com/channel/UCvYes_0afVM6GeTTFzELW4Q/videos'},
        {"category_id": "国际", "id": 15, "url": 'https://www.youtube.com/channel/UCDAMXqexiNMSzN_Vcwj72AQ/videos'},
        {"category_id": "推荐", "id": 16, "url": 'https://www.youtube.com/channel/UCc1rNJSBIks2LUsG2vYeZWA/videos'},
        {"category_id": "推荐", "id": 17, "url": 'https://www.youtube.com/channel/UCOUrdmzTUEYtyb2-xypZPJw/videos'},
        {"category_id": "推荐", "id": 18, "url": 'https://www.youtube.com/channel/UChhLcLteJ_3rHyBvNZQ7wmA/videos'},
        {"category_id": "娱乐", "id": 19, "url": 'https://www.youtube.com/channel/UCAe-YHMi71EJxUJyMXrQRoA/videos'},
        {"category_id": "科技", "id": 20, "url": 'https://www.youtube.com/channel/UCMUnInmOkrWN4gof9KlhNmQ/videos'},
        {"category_id": "娱乐", "id": 21, "url": 'https://www.youtube.com/user/mole44515829Video2/videos'},
        {"category_id": "旅游", "id": 22, "url": 'https://www.youtube.com/c/臉與魏魏/videos'},
        {"category_id": "娱乐", "id": 24, "url": 'https://www.youtube.com/channel/UCaQO2Ud6a3xKZSXLI-y4dcQ/videos'},
        {"category_id": "推荐", "id": 25, "url": 'https://www.youtube.com/channel/UCLgGLSFMZQB8c0WGcwE49Gw/videos'},
        {"category_id": "推荐", "id": 26, "url": 'https://www.youtube.com/channel/UCPgGtH2PxZ9xR0ehzQ27FHw/videos'},
        {"category_id": "推荐", "id": 28, "url": 'https://www.youtube.com/c/腦補給/videos'},
        {"category_id": "推荐", "id": 29, "url": 'https://www.youtube.com/channel/UCoYXquvvgPN4Bfmim021psg/videos'},
        {"category_id": "娱乐", "id": 30, "url": 'https://www.youtube.com/channel/UCD5a0H5XvzCtAGc_I__r2HA/videos'},
        {"category_id": "旅游", "id": 32, "url": 'https://www.youtube.com/channel/UCyzp22iMp1GWzrAcqTBUEaw/videos'},
        {"category_id": "旅游", "id": 33, "url": 'https://www.youtube.com/user/settour0401/videos'},
        {"category_id": "推荐", "id": 34, "url": 'https://www.youtube.com/channel/UCIOneg__NYowDmP8zrgtA7g/videos'},
        {"category_id": "科技", "id": 35, "url": 'https://www.youtube.com/channel/UCE3MUYjVHag9cSrNX4i28ew/videos'},
        {"category_id": "科技", "id": 36, "url": 'https://www.youtube.com/channel/UCxb_lmEefeVV8RTp9OY2AsA/videos'},
        {"category_id": "国际", "id": 37, "url": 'https://www.youtube.com/channel/UCRByPS00RZsAUe2DTCoHuFQ'},
        {"category_id": "旅游", "id": 39, "url": 'https://www.youtube.com/c/XuanLin%E6%9E%97%E5%AE%A3/videos'},
        {"category_id": "美食", "id": 40, "url": 'https://www.youtube.com/channel/UCFc1KeRhKjqmWEvNvcZ-EJQ/videos'},
        {"category_id": "美食", "id": 41, "url": 'https://www.youtube.com/c/Amandatastes/videos'},
        {"category_id": "美食", "id": 42, "url": 'https://www.youtube.com/c/MagicIngredients/videos'},
        {"category_id": "美食", "id": 43, "url": 'https://www.youtube.com/channel/UChcB3_gYZR2ps0vHiHOpNrQ/videos'}
     ]
    
    links_list.each do |spid|
      category = Category.find_by(name:spid[:category_id])  
      #MedialSpider.find_by(url:spid[:url]).update(category_id:category&.id)
      MedialSpider.find_or_create_by(url:spid[:url], category_id:category&.id, medial_type:1, spider_target_id: 4)
    end
  end


  # 导入视频：
  def self.gaoxiao_init
    videos = %w(https://www.youtube.com/c/SupercarBlondie/videos
            https://www.youtube.com/c/HALCYONphoto/videos
            https://www.youtube.com/c/HartnettMedia/videos
            https://www.youtube.com/c/NIGHTRIDEEE/videos
            https://www.youtube.com/c/LJWF_official/videos
            https://www.youtube.com/c/UnripeTV/videos
            https://www.youtube.com/user/SemenixPcgaming/videos
            https://www.youtube.com/channel/UCz0ONCn6eRcDJGsUzupc3TA/videos
            https://www.youtube.com/c/Treble%E8%BF%BD%E7%90%83/videos
            https://www.youtube.com/channel/UC7jc7c5vuY3sDPnwXmrsM6g/videos
            https://www.youtube.com/channel/UCYGmb-I0stcAKMJnlbMZcOw/videos
            https://www.youtube.com/channel/UCyG7zAV_2JlPnxhwDxZN6sA/videos
            https://www.youtube.com/channel/UCGEbrQPtZqnr_W-7i14kEhg/videos
            https://www.youtube.com/channel/UCykcNNIwJeJGGuLac6akyPw/videos
            https://www.youtube.com/channel/UCNFzrnH3napaamJ5w2lR6Rw/videos
            https://www.youtube.com/channel/UCiXJjvsRQEyT06x3YUwueVw/videos
            https://www.youtube.com/channel/UCKLcWcLKcXgA6jc_zVeJrTw/videos
            https://www.youtube.com/channel/UCwUFx_z61wqMV8zTUVDNV1w/videos
            https://www.youtube.com/channel/UC3UvP6c-zawggshLv85Ylng/videos
            https://www.youtube.com/c/%E7%8B%90%E7%8B%B8%E7%89%A7%E5%A0%B4foxranch/videos
            https://www.youtube.com/c/BLACKPINKOFFICIAL/videos
            https://www.youtube.com/c/sheephoho/videos
            https://www.youtube.com/channel/UCyrkQBlejP79tqw36uw1Sng/videos
            https://www.youtube.com/c/%E6%BA%9C%E6%BA%9C%E5%93%A5/videos
            https://www.youtube.com/c/Yoora/videos
            https://www.youtube.com/c/NuriaMaxo/videos
            https://www.youtube.com/c/STUDIOFTM/videos
            https://www.youtube.com/c/%E8%80%81%E5%AD%99%E8%81%8A%E6%B8%B8%E6%88%8F/videos
            https://www.youtube.com/channel/UC4P8jsqloj9e6eYCLz0yr7Q/videos
            https://www.youtube.com/channel/UC27M3BS9uxhJfPjYYys7y8w/videos
            https://www.youtube.com/c/iamlarrie123/videos
            https://www.youtube.com/c/SchelleyYuki/videos
            https://www.youtube.com/channel/UCnafe6M9Itwt08RFI51L6mw
            https://www.youtube.com/c/%E9%98%BF%E7%A6%8FThomas/videos
            https://www.youtube.com/channel/UCgChOCWnO8panmHaPN2D0-Q/videos
            https://www.youtube.com/c/gem0816/videos
            https://www.youtube.com/channel/UCQnW3NlXRx5X1_6vnvtu6xQ/videos
            https://www.youtube.com/user/ga20090939/videos
            https://www.youtube.com/channel/UCSUZuMJ4IWVFjbOlycq2tRA/videos
            https://www.youtube.com/c/TestingGames/videos
            https://www.youtube.com/c/%E5%A4%A7%E8%81%AA%E7%9C%8B%E7%94%B5%E5%BD%B1/videos
            https://www.youtube.com/c/captainmissile/videos
            https://www.youtube.com/channel/UCAQmUESq4GxO1b_iBCrYlTA/videos
            https://www.youtube.com/user/documentarycntv/videos
            https://www.youtube.com/channel/UCE3MUYjVHag9cSrNX4i28ew/videos
            https://www.youtube.com/c/ArekkzGaming/videos
            https://www.youtube.com/channel/UC4FLi-iZqxuK3kIqzivoDaw/videos
            https://www.youtube.com/channel/UCqgoxtfU-5ChmMTL-qo1c1A/videos
            https://www.youtube.com/c/%E5%87%B0%E5%AE%B6%E8%A9%95%E6%B8%ACifengTech/videos
            https://www.youtube.com/hunantv/videos
            https://www.youtube.com/channel/UCHV8lZJsXdW8lOFr2z8WPcg/videos
            https://www.youtube.com/channel/UCsdLbTwziL6Tg97swkuThSg/videos
            https://www.youtube.com/user/MrLiz0908/videos
            https://www.youtube.com/c/BIGdongdong/videos
            https://www.youtube.com/channel/UCpzx9sMpCwKP_xTwoYZx7lA/videos
            https://www.youtube.com/c/Jiafeimao/videos
            https://www.youtube.com/channel/UC7RL3bksyvu7rH7T6KFFkjw/videos
            https://www.youtube.com/c/Jing94993/videos
            https://www.youtube.com/channel/UCCObFBf0GKZMRfBH3CCv_ug/videos
            https://www.youtube.com/channel/UCYQPTeY3HOk0BprrGuCWCaA/videos
            https://www.youtube.com/c/NetflixAsia
            https://www.youtube.com/c/HamsterLow/videos
            https://www.youtube.com/c/%E8%B6%85%E7%B2%92%E6%96%B9/videos
            )
    videos.each do |v|        
      MedialSpider.find_or_create_by(url:v, category_id:7, medial_type:1, spider_target_id: 4, need_approve:0, web_site:"用户主页-视频", tags_str:"学生")
    end
  end


end
