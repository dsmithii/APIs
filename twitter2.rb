require 'launchy'
require 'oauth'
require 'yaml'
require 'json'

class Status
  #
  attr_accessor :user, :msg

  def initialize(user, msg)
    @user = user
    @msg = msg
  end
end

class User

  attr_accessor :statuses, :user_name, :followers, :followed_users

  def initialize(name)
    @user_name = name
    @statuses = []
  end

  def statuses
    @statuses
  end

  def followers

  end

end

class EndUser < User

  CONSUMER_KEY = "cqdStM5yZL8TDrpEsEXtcw"
  CONSUMER_SECRET = "wGIrJLxMJxXtWpLf3xwcWF3Yh3JAZgFtywxATxAc5w"
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  attr_accessor :access_token

  def initialize(name)
    @access_token = nil
    super(name)
  end

  def self.login(username)

    @@current_user = EndUser.new(name)
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    Launchy.open(authorize_url)
    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    @@access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier)
  end

  def self.access_token
    @@access_token
  end

  def self.current_user
    @@current_user
  end

  def self.timeline ## is home_timeline correct?
    JSON.parse(@@access_token.get("https://api.twitter.com/1.1/statuses/home_timeline.json").body)
  end

  def self.dm(target_user, msg) #direct msg
    @@access_token.post("https://api.twitter.com/1/direct_messages/new.json", {:screen_name => target_user, :text => msg})
    @@current_user.statuses << Status.new(@@current_user, msg)
  end

  def self.tweet(msg)
    @@access_token.post("https://api.twitter.com/1.1/statuses/update.json?status=#{msg}")
    @@current_user.statuses << Status.new(@@current_user, msg)
  end

  #08etw47u9er

end