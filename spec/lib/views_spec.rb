require 'spec_helper'
require 'ruby-debug'
describe "View Action" do
  before :each do
    @user = create :User, id: 10
    @author = create :User, id: 30
    @post = create :Post, id: 100
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
    it "should increase the post views counter" do
      @post.data["views"].to_i.should eq @post.initial_data["views"].to_i + 1
    end
  end

end
