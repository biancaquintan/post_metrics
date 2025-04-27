class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, :body, :ip, presence: true
  validates :ip, format: { with: /\A(?:\d{1,3}\.){3}\d{1,3}\z/, message: "is invalid" }
end
