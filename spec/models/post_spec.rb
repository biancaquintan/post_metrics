require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:ip) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'behaviors' do
    let(:user) { create(:user) }

    it 'belongs to a user' do
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end
  end
end
