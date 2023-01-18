module Time::FloatEpochConverter
  def self.from_json(value : JSON::PullParser) : Time
    Time.unix(value.read_float.to_i64)
  end

  def self.to_json(value : Time, json : JSON::Builder) : Nil
    json.number(value.to_unix)
  end
end
