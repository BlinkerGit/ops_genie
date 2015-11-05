# Author: https://github.com/timruffles
# Borrowed from: https://gist.github.com/timruffles/2780508
module HashConverter
  class << self
    def to_camel_case obj
      case obj
      when Hash
        obj.inject({}) do |h,(k,v)|
          v = to_camel_case(v)
          h[lower_camelize(k.to_s)] = v
          h
        end
      when Array
        obj.map {|m| to_camel_case(m) }
      else
        obj
      end
    end

    private

    def lower_camelize(string)
		  string.gsub(/_(.)/) {|e| $1.upcase}
	  end
  end
end
