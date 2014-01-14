require 'spec_helper'
require 'ruby-debug'
describe "View Action" do
  before :each do
    @user = create :User, id: 10
    @author = create :User, id: 30
    @post = create :Post, id: 100
    @post_daily = create :PostDaily, {day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end

  before :each do
    open("http://#{HOST}/views?post=#{@post.id}&user=#{@user.id}&author=#{@author.id}")
  end

  describe "User" do
    it "should increase the views of the user by one" do
      @user.data["views"].to_i.should eq @user.initial_data["views"].to_i + 1
    end
  end

  describe "Author" do
    it "should increase the post's author num of time he's been viewed" do
      @author.data["views_got"].to_i.should eq @author.initial_data["views_got"].to_i + 1
    end
  end

  describe "Post" do
    it "should increase the post reads counter" do
      @post.data["reads"].to_i.should eq @post.initial_data["reads"].to_i + 1
    end
  end

  describe "PostDaily" do
    it "should increase post views in post daily" do
      @post_daily.set["post_#{@post.id}"].to_i.should eq @post_daily.initial_set["post_#{@post.id}"].to_i + 1
    end
  end

  describe "UserDaily" do
    it "should increase the daily reads of the user by one" do
      @user_daily.data["reads"].to_i.should eq @user_daily.initial_data["reads"].to_i + 1
    end

    it "should increase the daily reads of the author by one" do
      @author_daily.data["reads_got"].to_i.should eq @author_daily.initial_data["reads_got"].to_i + 1
    end

    it "should set a TTL for the objects" do
      $redis.ttl(@user_daily.key).should > 0
      $redis.ttl(@author_daily.key).should > 0
    end
  end

end
