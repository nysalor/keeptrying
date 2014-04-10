module Keeptrying
  class Command
    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def parse_args
      @action = @argv[0] || 'recent'

      unless @argv[1] == '-a'
        { keep: '-k', problem: '-p', try: '-t' }.each do |k, v|
          if @argv[1] == v
            @tag = k
          end
        end
      end
    end

    def parse_days
      @today = Date.today
      @days = @argv[2] || 7
      @to = Time.now
      @from = (Date.today - @days.to_i).to_time
    end

    def parse_body
      @body = @argv[2]
    end

    def display(list)
      if list.empty?
        puts "database is empty."
      else
        list.each do |entry|
          puts "#{Time.at(entry[:utc])} #{colored_tag(entry[:tag_id])} #{entry[:body]}#{' (done)' if entry[:done] > 0}"
        end
      end
    end

    def show_list
      display kpt.get
    end

    def show
      parse_days
      kpt.select @from, @to, @tag
      show_list
    end

    def all
      parse_days
      kpt.select @from, @to, @tag, true
      show_list
    end

    def write
      if @tag
        if (@argv[2])
          kpt.write @tag, @argv[2]
        else
          tempfile.close false
          run_editor
          tempfile.open
          kpt.write @tag, tempfile.read
          tempfile.close true
        end
      else
        puts "missing tag. tag must be '-k or -p or -t"
      end
    end

    def done
      @days = @argv[2].to_i
      if @days > 0
        kpt.select 0, (Date.today - @days.to_i).to_time
      else
        kpt.select
      end
      kpt.done
    end

    def execute
      parse_args
      case @action
      when 'show'
        show
      when 'recent'
        show
      when 'all'
        all
      when 'write'
        write
      when 'done'
        done
      end
    end

    private

    def tempfile
      @tempfile ||= Tempfile.open('kpt')
    end

    def run_editor
      system "#{ENV["EDITOR"]} #{tempfile.path}"
    end

    def kpt
      @kpt ||= Kpt.new
    end

    def colored_tag(id)
      color = [:blue, :red, :yellow]
      kpt.tags[id].to_s.send(color[id])
    end
  end
end
