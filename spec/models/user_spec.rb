require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:queue_items).order(:position) }

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end

  describe "#queued_video?" do
    it "returns trun when the user queued the video" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:queue_item, user: user, video: video)
      user.queued_video?(video).should be_true
    end

    it "returns false when the user not queued the video" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:queue_item, user: user)
      user.queued_video?(video).should be_false
    end
  end

  describe "#follows?" do
    it "returns true if current user has realitionship with another user" do
      sam = Fabricate(:user)
      vivian = Fabricate(:user)
      Fabricate(:relationship, leader: vivian, follower: sam)
      expect(sam.follows?(vivian)).to be_true
    end

    it "returns false if curren user not following another user" do
      sam = Fabricate(:user)
      vivian = Fabricate(:user)
      expect(sam.follows?(vivian)).to be_false
    end
  end

  describe "#follow" do
    it "follows another user" do
       sam = Fabricate(:user)
       vivian = Fabricate(:user)
       sam.follow(vivian)
       expect(sam.follows?(vivian)).to be_true
    end
    it "does not follow oneself" do
       sam = Fabricate(:user)
       sam.follow(sam)
       expect(sam.follows?(sam)).to be_false
       
    end
  end
end
