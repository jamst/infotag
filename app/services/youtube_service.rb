class YoutubeService
  def self.aa
    agent = Mechanize.new
    cc1 = Video.find_or_create_by(title: "生命科学", parent_id: 0)
    resp = agent.get("https://www.youtube.com/channel/UCCbYWuRvD2q_3qSla1gNHtg/videos").search("li.subnav_cat dl.sub_dl")
    resp.each do |e1|
      catalog_name2 = e1.search(".sub_dt a").first.children.first.text.strip
    end
  end

  def nokogiri_test
    source_data = HTTParty.get("https://www.youtube.com/channel/UCCbYWuRvD2q_3qSla1gNHtg/videos")
    html_obj = Nokogiri::HTML(source_data)
    result = html_obj.css('div.contents').at_css('[id="items"]')   

    # .search('nav ul.menu li a', '//article//h2').each do |link|
    #  puts link.content
  end

end