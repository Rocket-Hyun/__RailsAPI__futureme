CarrierWave.configure do |config|

config.fog_credentials = {
  provider: 'AWS',
  aws_access_key_id: "#{ENV['AWSAccessKeyId']}",
  aws_secret_access_key: "#{ENV['AWSSecretKey']}",
  region:               "#{ENV['AWS_REGION']}",                  # optional, defaults to 'us-east-1'
  endpoint:             'http://s3.amazonaws.com' # optional, defaults to nil
}

config.fog_directory = 'futureme-pic'

end
