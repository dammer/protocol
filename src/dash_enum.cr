# Makes enum parser to underatand dasheized values
#
# @[DashEnum]
# enum ServiceWorkerResponseSource
#   CacheStorage # 'cache-storage',
#   HttpCache    # 'http-cache',
#   FallbackCode # 'fallback-code',
#   Network      # 'network',
# end
#
# struct Request
#   include JSON::Serializable
#   @[JSON::Field(key: "responseSource")]
#   getter response_source : ServiceWorkerResponseSource
# end
#
# ServiceWorkerResponseSource.parse("fallback-code")
# => FallbackCode
#
# Request.from_json(%({"responseSource":"http-cache"}))
# => Request(@response_source=HttpCache)

annotation DashEnum
end

struct Enum
  def self.parse?(string : String) : self?
    {% begin %}
      {% if @type.annotation(DashEnum) %}
        case string.tr("-", "_").camelcase.downcase
      {% else %}
        case string.camelcase.downcase
      {% end %}
      {% for member in @type.constants %}
        when {{member.stringify.camelcase.downcase}}
          new({{@type.constant(member)}})
      {% end %}
        else
          nil
        end
    {% end %}
  end
end
