require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'behaviors' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it 'belongs to a post and a user' do
      rating = create(:rating, user: user, post: post)
      expect(rating.user).to eq(user)
      expect(rating.post).to eq(post)
    end

    it 'is invalid with value less than 1' do
      rating = build(:rating, value: 0)
      expect(rating).to_not be_valid
    end

    it 'is invalid with value greater than 5' do
      rating = build(:rating, value: 6)
      expect(rating).to_not be_valid
    end
  end
end
