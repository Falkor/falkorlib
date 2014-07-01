require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rubygems'
require 'bundler/setup'
Bundler.setup

require 'fileutils'
require 'pathname'


$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'falkorlib'
require 'falkorlib/common'
require 'falkorlib/git'

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

# require 'minitest/autorun'
# require 'minitest/spec'

# class MiniTest::Spec
#     attr_reader :tmp_path
#     before do
#         @tmp_path = Pathname.new(__FILE__).dirname.dirname.join('tmp').expand_path
#     end
# end

# credits to [gabebw](http://gabebw.wordpress.com/2011/03/21/temp-files-in-rspec/)
module UsesTempFiles
  def self.included(example_group)
    example_group.extend(self)
  end

  def in_directory_with_file(file)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      Dir.chdir(@tmp_dir)

      FileUtils.mkdir_p(File.dirname(file))
      FileUtils.touch(file)
    end

    define_method(:content_for_file) do |content|
      f = File.new(File.join(@tmp_dir, file), 'a+')
      f.write(content)
      f.flush # VERY IMPORTANT
      f.close
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end
end
