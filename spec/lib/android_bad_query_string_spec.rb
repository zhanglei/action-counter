require 'spec_helper'

describe "Android bad Query String with amp;" do
  before :each do
    @user = create :User, id: 100
    @other_user = create :User, id: 200
    open("http://#{HOST}/follow?user=#{@user.id}&amp;other_user=#{@other_user.id}")
  end


  describe "Follow action as a use case" do

    it "should have a correct redis key for user" do
      $redis.keys("*").include?("User_#{@user.id}").should be_true
    end


    it "should have a correct redis key for other user" do
      $redis.keys("*").include?("User_#{@other_user.id}").should be_true
    end
  end
end

describe "Android login with question mark in Query String values" do
  describe "login as use case" do
    it "should remove the question mark from the value" do
      @user = create :User
      open("http://#{HOST}/logins?user=#{@user.id}?")
      $redis.keys("*").include?("User_#{@user.id}").should be_true
      $redis.keys("*").include?("User_#{@user.id}?").should be_false
      @user.data["logins"].to_i.should eq @user.initial_data["logins"].to_i + 1
    end
  end

  describe "follow as use case" do
    it "should remove the question mark from the value" do
      @user = create :User
      @other_user = create :User
      open("http://#{HOST}/follow?user=#{@user.id}?&other_user=#{@other_user.id}")
      $redis.keys("*").include?("User_#{@user.id}").should be_true
      $redis.keys("*").include?("User_#{@user.id}?").should be_false
      @user.data["follow"].to_i.should eq @user.initial_data["follow"].to_i + 1
    end
  end

  describe "feature as use case for array values" do
    it "should remove the question mark from all the values of the array param" do
      @user = create :User
      @channels = ["site", "mobile", "telegraph"]
      open("http://#{HOST}/feature?user=#{@user.id}&locale=en&countcategory=1&category=stam&" + @channels.map { |c| "channel[]=#{c}"}.join("?&") )
      @channels.each do |channel|
        @user.data["feature_#{channel}"].to_i.should eq @user.initial_data["feature_#{channel}"].to_i + 1
      end
    end
  end
end
