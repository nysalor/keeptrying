module Keeptrying
  class Query
    attr_accessor :from, :to, :tag, :with_done, :only_done, :entries, :limit

    def self.attribute_names
      %w(from to tag with_done only_done)
    end

    def self.default_options
      {
        with_done: false,
        only_done: false
      }
    end

    def initialize(entries, opts = { })
      @entries = entries
      @executed = false
      @prepared = false
      self.attributes = opts
    end

    def attributes
      attr = { }
      self.class.attribute_names.each do |k|
        attr[k] = self.send(k)
      end
      attr
    end

    def attributes=(opts)
      opts = self.class.default_options.merge(opts)
      self.class.attribute_names.each do |k|
        self.send "#{k}=", opts[k]
      end
    end

    def prepare
      if @from
        @entries = @entries.where('utc >= ? ', from.to_i)
      end
      if @to
        @entries = @entries.where('utc <= ?', to.to_i)
      end
      if @tag
        @entries = @entries.where(tag_id: Keeptrying.tag_id(tag))
      end

      if @only_done
        @entries = @entries.where(done: 1)
      else
        unless @with_done
          @entries = @entries.where(done: 0)
        end
      end
      @prepared = true
    end

    def get(num = nil)
      @prepared || prepare
      if (num && @limit && (@limit != num))
        @limit = num
        @executed = false
      elsif num
        @limit = num
      end
      if @executed
        @result
      elsif @limit
        @result = @entries.limit(@limit).all
      else
        @result = @entries.all
      end
      @executed = true
      @result
    end

    def done
      @prepared || prepare
      @entries.update done: 1
      @executed = true
    end

    def truncate
      @entries.delete
    end
  end
end
