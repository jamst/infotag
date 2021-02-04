class VideoController < ActionController::Base

  around_action :benchmark_filter
 
  # 方法执行时间测速
  def benchmark_filter
   start_time1 = Time.now.to_datetime.strftime('%Q').to_i
   yield # 这里让出来执行Action动作
   start_time_bt = (Time.now.to_datetime.strftime('%Q').to_i - start_time1)
   Rails.logger.tagged("资讯流接口请求取值耗时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") }
   Rails.logger.tagged("资讯流接口请求取值耗时超时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") } if start_time_bt > 1000
  end

  # 用户爬取缓存视频后更新地址回调
  def up_cache_videos
    # /videos/up_cache_videos
    # 放到异步任务去处理，直接返回结果给请求端
    data = params[:data]
    data.keys.each do |video_key|
      video = Video.find_by(id:video_key)
      video.update(location_source_url:"#{Video::LOCATION_SOURCE_DOMAIN}/videos/#{data[video_key]}.mp4")
    end
  end

end
