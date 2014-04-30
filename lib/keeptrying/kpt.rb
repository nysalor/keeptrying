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
      entries.insert tag_id: Keeptrying.tag_id(tag), body: body, utc: Time.now.to_i
    end

    def query
      Keeptrying::Query.new(entries)
    end

    private

    def entries
      @entries ||= @db[:entries]
    end
  end
end
