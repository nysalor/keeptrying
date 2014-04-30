#require "keeptrying/version"
require 'rubygems'
require 'fileutils'
require 'tempfile'
require 'sequel'
require 'colored'
require 'keeptrying/kpt'
require 'keeptrying/command'
require 'keeptrying/version'
require 'keeptrying/query'

module Keeptrying
  class << self
    def tags
      [:keep, :problem, :try]
    end

    def tag_id(tag)
      tags.index tag
    end

    def tag(id)
      tags[id]
    end
  end
end
