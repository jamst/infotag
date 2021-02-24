class AliyunOssService
  require 'aliyun/oss'
  require 'aliyun/sts'
  # 文档地址：https://github.com/aliyun/aliyun-oss-ruby-sdk/blob/master/README-CN.md

  # 自定义域名绑定了OSS的一个bucket，所以用这种方式创建的client不能进行 list_buckets操作
  # 在{Aliyun::OSS::Client#get_bucket}时仍需要指定bucket名字，并且要与域名所绑定的bucket名字相同
  def self.new_client
    endpoint = CONFIG.ao_endpoint
    access_key_id = CONFIG.ao_access_key_id
    access_key_secret = CONFIG.ao_access_key_secret
    client = ::Aliyun::OSS::Client.new(
      :endpoint => endpoint,
      :access_key_id => access_key_id,
      :access_key_secret => access_key_secret,
      :cname => true)
  end
  
  # sts 阿里云临时安全令牌（Security Token Service，STS）是阿里云提供的一种临时访问权限管理服务
  # 获取sts相关信息
  def self.get_sts_client_info
    endpoint = CONFIG.ao_endpoint
    access_key_id = CONFIG.ao_access_key_id
    access_key_secret = CONFIG.ao_access_key_secret
    sts = Aliyun::STS::Client.new(
      access_key_id: access_key_id,
      access_key_secret: access_key_secret)

    # role_arn(RAM角色的ARN)，角色ARN是角色的资源名称（Aliyun Resource Name，简称ARN）。角色ARN全局唯一，用来指定具体的RAM角色。
    role_arn = "acs:ram::1142987040955175:role/aliyunossrole"
    # assume_role(扮演角色)，扮演角色是实体用户获取角色身份的安全令牌的方法。一个实体用户调用STS API AssumeRole可以获得角色的安全令牌，使用安全令牌可以访问云服务API
    token = sts.assume_role(role_arn, 'web_user')

    {endpoint: endpoint, access_key_id: token.access_key_id, access_key_secret: token.access_key_secret, sts_token: token.security_token, bucket: CONFIG.ao_bucket_name}
  end
    
  def self.get_bucket
    client = new_client
    bucket_name = CONFIG.ao_bucket_name
    client.get_bucket(bucket_name)
    # bucket = client.get_bucket(bucket_name)
    # objects = bucket.list_objects
    # objects.each{ |o| puts "Object: #{o.key}, type: #{o.type}, size: #{o.size}" }
  end
  
  # 该方法弃用，文件由前端调用对应aliyun oss sdk接口上传，不通过服务器上传，占用带宽
  # 上传本地文件
  def self.put_object(file, file_path)
    bucket = get_bucket
    bucket.put_object(file_path, :file => file)
  end
  
  # 获取文件对应的下载地址
  def self.get_download_url(file_path)
    endpoint = CONFIG.ao_endpoint
    endpoint + "/" + file_path
  end
  
  # 使用oss中的文件，重新上传一个到oss中，路径为new_file_path
  def self.copy_object(old_file_path, new_file_path)
    bucket = get_bucket
    old_file_exists = bucket.object_exists?(old_file_path)
    return false if !old_file_exists
    bucket.copy_object(old_file_path, new_file_path)
    return true
  end
  
  # cdn-刷新节点上的文件内容
  # 官方文档地址: https://help.aliyun.com/document_detail/27200.html?spm=a2c4g.11186623.2.21.5f783161opc8e4
  def self.reflash_cdn(file_path)
    file_path = get_download_url(file_path)
    url = "https://cdn.aliyuncs.com"
    action = "RefreshObjectCaches"
    params = {Action: action, Version: "2018-05-10", Format: "JSON", AccessKeyId: CONFIG.ao_access_key_id, SignatureMethod: "HMAC-SHA1", Timestamp: Time.now.utc.iso8601, SignatureVersion: "1.0", SignatureNonce: Time.now.to_datetime.strftime('%Q'), ObjectPath: file_path}
    params[:Signature] = get_signature(params, 'POST')
    HTTParty.post(url, body: params, headers: {'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8'})
  end
    
  def self.get_signature(params, http_method)
    params = (params.sort {|a,b| a.first <=> b.first}).to_h
    string_to_sign = http_method + "&" + CGI.escape('/') + "&" + CGI.escape(params.to_param)
    key = CONFIG.ao_access_key_secret + "&"
    digest = OpenSSL::Digest.new('sha1')
    Base64.strict_encode64(OpenSSL::HMAC.digest(digest, key, string_to_sign))
  end
end