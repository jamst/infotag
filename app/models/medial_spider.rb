class MedialSpider < ApplicationRecord

  enum status: { disabled: -1, enabled: 0 }
  enum medial_type: { info: 0, video: 1 }
  default_scope -> {where(is_delete: 0)}
  belongs_to :spider_target
  belongs_to :category
  has_many :videos, -> {where(medial_type: "video")}, class_name: 'MedialSpider'
  has_many :infos, -> {where(medial_type: "video")}, class_name: 'MedialSpider'

  # 统计爬取条数
  def count_size
    if medial_type == "video"
      Video.where(medial_spider_id:self.id).count
    else
      Info.where(medial_spider_id:self.id).count
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
      MedialSpider.find_by(url:spid[:url]).update(category_id:category&.id)
      #MedialSpider.find_or_create_by(url:spid[:url], category_id:category&.id, medial_type:1, spider_target_id: 4)
    end
  end

end
