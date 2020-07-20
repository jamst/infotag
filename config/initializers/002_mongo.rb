module Rails
  def self.mongo
    @_mongo ||= begin
                  mongo_config = CONFIG.mongo.to_hash
                  hosts = mongo_config.delete(:hosts)
                  Mongo::Client.new(hosts, mongo_config)
                end
  end
end
