$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'falkorlib'
require 'falkorlib/common'
require 'falkorlib/gitflow'

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end
  result
end
