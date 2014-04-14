module Keeptrying
  class Kpt
    class << self
      def db
        @db ||= Sequel.connect("sqlite://#{db_file}")
      end

      def db_file
        ENV['KPT_DB'] || File.join(ENV['HOME'], '.kpt', 'kpt.sqlite')
      end

      def create_db
        db.create_table :entries do
          primary_key :id
          Integer :tag_id
          String :body
          Integer :utc
          Integer :done, default: 0
        end
      end

      def setup
        unless File.exists?(db_file)
          FileUtils.mkpath File.dirname(db_file)
          Sequel.sqlite db_file
          create_db
        end
      end
    end

    def initialize
      self.class.setup
      @db = self.class.db
    end

    def write(tag, body)
      entries.insert tag_id: tag_id(tag), body: body, utc: Time.now.to_i
    end

    def query(from = nil, to = nil, tag = nil, all = false)
      @entries = all ? entries : entries.where(done: 0)

      if from
        @entries = entries.where('utc >= ? ', from.to_i)
      end
      if to
        @entries = entries.where('utc <= ?', to.to_i)
      end
      if tag
        @entries = entries.where(tag_id: tag_id(tag))
      end
    end

    def get(num = nil)
      if num
        entries.limit num
      else
        entries.all
      end
    end

    def done
      entries.update done: 1
    end

    def tags
      [:keep, :problem, :try]
    end

    def tag_id(tag)
      tags.index tag
    end

    private

    def entries
      @entries ||= @db[:entries]
    end
  end
end
