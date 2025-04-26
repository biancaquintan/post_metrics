require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:login) }
  end

  describe 'associations' do
    it { should have_many(:posts) }
    it { should have_many(:ratings) }
  end

  describe 'behaviors' do
    let(:user) { create(:user) }

    it 'can have many posts' do
      post = create(:post, user: user)
      expect(user.posts).to include(post)
    end

    it 'can have many ratings' do
      post = create(:post, user: user)
      rating = create(:rating, user: user, post: post)
      expect(user.ratings).to include(rating)
    end
  end
end
