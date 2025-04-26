class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, :body, :ip, presence: true
end
