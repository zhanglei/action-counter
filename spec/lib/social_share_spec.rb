require 'spec_helper'
describe "ActionCounter" do

  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
    @user_weekly = create :UserWeekly, { user: @author.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end


  [:post_page_likes, :post_page_gplus,  :tweets, :shares, :post_page_facebook_shares, :post_page_gplus_shares].each do |action|
    before :all do
      open("http://#{HOST}/#{action}?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end
    describe action.to_s do
       it "should increase the user's num of #{action} by 1" do
        @user.data["#{action}"].to_i.should eq @user.initial_data["#{action}"].to_i + 1
      end

      it "should increase the post's author num of #{action}_got he got" do
        @author.data["#{action}_got"].to_i.should eq @author.initial_data["#{action}_got"].to_i + 1
      end

      it "should increase the posts num of #{action} by 1" do
        @post.data["#{action}"].to_i.should eq @post.initial_data["#{action}"].to_i + 1
      end

      it "should increase the author's UserWeekly #{action} count" do
        @user_weekly.data["#{action}"].to_i.should eq @user_weekly.initial_data["#{action}"].to_i + 1
      end

      it "author num of #{action} he got should be equal to the number of #{action} in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
        @author.data["#{action}_got"].should eq @user_weekly.data["#{action}"]
      end

      describe "UserDaily" do
        it "should increase the daily #{action} of the user by one" do
          @user_daily.data["#{action}"].to_i.should eq @user_daily.initial_data["#{action}"].to_i + 1
        end

        it "should increase the daily #{action} of the author by one" do
          @author_daily.data["#{action}_got"].to_i.should eq @author_daily.initial_data["#{action}_got"].to_i + 1
        end

        it "should set a TTL for the objects" do
          $redis.ttl(@user_daily.key).should > 0
          $redis.ttl(@author_daily.key).should > 0
        end
      end
    end
  end

  describe "'authour' typo" do
    before :all do
      open("http://#{HOST}/shares?user=#{@user.id}&authour=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of shares by 1" do
      @user.data["shares"].to_i.should eq @user.initial_data["shares"].to_i + 2
    end

    it "should increase the post's author num of shares he got" do
      @author.data["shares_got"].to_i.should eq @author.initial_data["shares_got"].to_i + 2
    end

    it "should increase the posts num of shares by 1" do
      @post.data["shares"].to_i.should eq @post.initial_data["shares"].to_i + 2
    end

    it "should increase the author's UserWeekly shares count" do
      @user_weekly.data["shares"].to_i.should eq @user_weekly.initial_data["shares"].to_i + 2
    end

    it "author num of shares he got should be equal to the number of shares in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["shares_got"].should eq @user_weekly.data["shares"]
    end

    describe "UserDaily" do
      it "should increase the daily shares of the user by one" do
        @user_daily.data["shares"].to_i.should eq @user_daily.initial_data["shares"].to_i + 2
      end

      it "should increase the daily shares of the author by one" do
        @author_daily.data["shares_got"].to_i.should eq @author_daily.initial_data["shares_got"].to_i + 2
      end
    end
  end
end
