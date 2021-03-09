class AddStrategyWordToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :spider_origin_videos, :strategy_word, :text, comment: "匹配策略黑词"
    add_column :videos, :strategy_word, :text, comment: "匹配策略黑词"
  end
end
