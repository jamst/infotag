class ImageService

  require "mini_magick"

  def self.tmp_dir
    dir = "#{Rails.root}/public/medial_images/compress"
    FileUtils.mkdir(dir) unless File.exists?(dir)
    dir
  end


  def self.compress(image_path, options = {quality: "90%"})
    to_path = "#{tmp_dir}/compress_#{SecureRandom.uuid.to_s.strip}.png"
    image = MiniMagick::Image.open image_path
    image.resize "480x360"
    image.combine_options do |b|
      b.strip
      b.quality options[:quality]
    end
    image.write to_path
    to_path
  end

end
