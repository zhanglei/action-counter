class RedisObjectFactory
  attr_reader :type, :key, :ids, :id

  class << self
    attr_accessor :redis
  end

  def initialize(type_, ids_)
    @type = type_
    @ids = ids_
    fix_week_year_id
    @id = @ids.values.join("_")
    @key = "#{@type}_#{@id}"
    key_type = self.class.redis.type(@key)
    initial_data if key_type == "hash" || key_type == "none"
    initial_set if key_type == "zset" || key_type == "none"
  end

  def data
    data = Hash.new(0)
    data.merge(self.class.redis.hgetall @key)
  end

  def initial_data
    @initial_data ||= data
  end

  def initial_set
    @initial_set ||= set
  end

  def set
    set = Hash.new(0)
    set.merge(Hash[*$redis.zrange(key, 0, -1, withscores: true).flatten])
  end

  private
  def fix_week_year_id
    if @ids[:week_year]
      week = @ids[:week_year].first
      year = @ids[:week_year].last
      if week == "00"
        week = "52"
        year = year.to_i - 1
      end
      @ids[:week_year] = "#{week}_#{year}"
    end
  end
end
