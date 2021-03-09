class RecommendsController < ActionController::Base

  around_action :benchmark_filter
 
  # 方法执行时间测速
  def benchmark_filter
   start_time1 = Time.now.to_datetime.strftime('%Q').to_i
   yield # 这里让出来执行Action动作
   start_time_bt = (Time.now.to_datetime.strftime('%Q').to_i - start_time1)
   Rails.logger.tagged("分类资讯流接口请求取值耗时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") }
   Rails.logger.tagged("分类资讯流接口请求取值耗时超时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") } if start_time_bt > 1000
  end

  
  # 索引推荐首页
  def index
    # /recommends
    flow_medias = {}
    flow_medias[:rcommend_list] = [{"name":"top","value":"全球头条","image_url":"red"},{"name":"synthesize","value":"综合推荐","image_url":"black"}]
    flow_medias[:top] = $redis.get("top_list").present? ?  eval($redis.get("top_list")) : []
    flow_medias[:synthesize] = $redis.get("synthesize_list").present? ? eval($redis.get("synthesize_list")) : []
    render json: flow_medias.to_json  and return
  end

  
  # 更多明细页面
  def detail
    # /recommends/detail
    # 页码
    page = params[:page].to_i
    # 每页条目
    page_limit = params[:limit].to_i
    # 类型
    recommend_type = params[:recommend_type]

    if page <= 1
      # 第一页获取缓存数据
      flow_medias = {}
      flow_medias[:rcommend_list] = [Recommend::RECOMMEND_TYPE[recommend_type.to_sym]]
      flow_medias[:detail] = $redis.get("#{recommend_type}_list").present? ?  eval($redis.get("#{recommend_type}_list")) : []
    else
      @recommends = Recommend.where(recommend_type: recommend_type).order(sort_live: :desc).page(page).per(page_limit)

      flow_medias = {}
      flow_medias[:rcommend_list] = [Recommend::RECOMMEND_TYPE[recommend_type.to_sym]]
      flow_medias[:detail] = []
      # 资讯
      @recommends.each do |_|
        flow_medias[:detail] << {recommend_type: recommend_type, recommend_id:_.id, title:_.title,url:_.url, mark_title:_.mark&.title, mark_url: _.mark&.url }
      end
    end
  
    render json: flow_medias.to_json  and return
  end
  

end