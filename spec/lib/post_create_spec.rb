require 'spec_helper'

describe "Post Created" do
  before :all do
    @user = create :User
    @user_weekly = create :UserWeekly, { user: @user.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
  end

  before :all do
    open("http://#{HOST}/post_create?user=#{@user.id}")
  end

  it "should increase the user's num of posts created by 1" do
    @user.data["post_create"].to_i.should eq @user.initial_data["post_create"].to_i + 1
  end

  it "should increase the user's weekly num of posts created" do
    @user_weekly.data["post_create"].to_i.should eq @user_weekly.initial_data["post_create"].to_i + 1
  end

end