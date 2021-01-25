class FileAttachment < ApplicationRecord
  belongs_to :attachment_entity, polymorphic: true

  default_scope -> {where(is_delete: 0)}
  
  # 添加内容到缓存
  def self.add_file_to_mongo(file, file_name=nil, obj=nil)
    grid = Rails.mongo.database.fs
    content_type = "image/png"
    begin
      file_name = file_name.present? ? file_name : file.original_filename
      store_dir = "aclconf/#{file_name}"
      grid.upload_from_stream(store_dir, file, content_type: content_type)
      obj = FileAttachment.create(name: file_name, content_type: content_type, file_size: file.size, path: store_dir)
      obj
    rescue => e
      e
    end
  end

  # 添加内容到缓存
  def self.web_file_to_mongo(file)
    grid = Rails.mongo.database.fs
    begin
      file_name = file.original_filename
      store_dir = "aclconf/#{get_random}_#{file_name}"
      grid.upload_from_stream(store_dir, file, content_type: file.content_type)
      obj = FileAttachment.create(name: file_name, content_type: file.content_type, file_size: file.size, path: store_dir)
      obj
    rescue => e
      e
    end
  end

  def self.get_random(len=10,chars=[])
    chars = ("0".."9").to_a if chars.blank?
    result = []
    len.times { |i| result << chars[rand(chars.size-1)] }
    result.join('')
  end

  # 获取web访问地址
  def get_file_path
    mongo_config = CONFIG.mongo.to_hash
    # "#{mongo_config[:download_host]}/#{mongo_config[:database]}/#{self.path}"
    "https://sz6.je2ci9.com/infoflow_pics/#{mongo_config[:database]}/#{self.path}"
  end

  # 直接mongodb获取文件流
  def find_url_file
    grid_file = Rails.mongo.database.fs.find_one(:filename => self.path)
    # 返回文件流
    grid_file.data
  end

end
