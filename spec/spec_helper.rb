$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'keeptrying'
require 'faker'
require 'timecop'
require 'pry'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
end

module FixtureHelpers
  def create_entry(sentence = random_sentence)
    @kpt.write tag, sentence
  end

  def create_entries(num)
    num.times.each { create_entry }
  end

  def tag
    %w(keep problem try).sample
  end

  def random_sentence
    Faker::Lorem.sentence
  end
end

module CaptureHelpers
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
end
