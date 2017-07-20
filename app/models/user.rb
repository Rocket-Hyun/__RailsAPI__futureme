class User < ApplicationRecord
  mount_uploader :body_pic, ImageUploader
end
