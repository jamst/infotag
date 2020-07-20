redis_url = "redis://#{CONFIG.redis_host}:#{CONFIG.redis_port}/#{CONFIG.redis_db}"

$redis_connection = Redis.new(url: redis_url, password: CONFIG.redis_pwd)
$redis = Redis::Namespace.new(CONFIG.redis_namespace, redis: $redis_connection)
Redis::Objects.redis = $redis