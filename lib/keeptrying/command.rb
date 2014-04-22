module Keeptrying
  class Command
    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def execute
      parse_args
      parse_days
      case @action
      when 'show', 's'
        show
      when 'recent', 'r'
        show
      when 'all', 'a'
        all
      when 'write', 'w'
        write
      when 'done', 'd'
        done
      when 'truncate', 't'
        truncate
      when 'help', 'h'
        help
      end
    end

    private

    def show
      parse_days
      kpt.query @from, @to, @tag
      output kpt.get
    end

    def all
      parse_days
      kpt.query @from, @to, @tag, true
      output kpt.get
    end

    def write
      if @tag
        if @argv[2]
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
      @days = @argv[1].to_i
      if @days > 0
        kpt.query @from, @to
      else
        kpt.query
      end
      kpt.done
    end

    def truncate
      @days = @argv[1].to_i
      if @days > 0
        kpt.query @from, @to
        kpt.truncate
      end
    end

    def help
      puts <<-EOS
      usage:
      kpt show [-k|p|t] [days] (or kpt s)
        show KPT entries
      kpt write -k|p|t [message] (or kpt w)
        write a KPT entry (if omit message, open editor)
      kpt done [days] (or kpt d)
        entries are marked with "done" flag.
      kpt all [-k|-p|-t] [days] (or kpt a)
        show entries (includes "done" entries)
      kpt truncate days (or kpt t)
        delete old entries
      EOS
    end

    def parse_days
      @today = Date.today
      if %w(done truncate).include?(@action)
        @days = @argv[1].to_i
        @from = 0
        @to = ago(@days)
      else
        @days = @argv[2] || 7
        @to = Time.now
        @from = ago(@days)
      end
    end

    def parse_args
      @action = @argv[0] || 'show'

      unless @argv[1] == '-a'
        { keep: '-k', problem: '-p', try: '-t' }.each do |k, v|
          if @argv[1] == v
            @tag = k
          end
        end
      end
    end

    def parse_body
      @body = @argv[2]
    end

    def output(list)
      if list.empty?
        puts "database is empty."
      else
        list.each do |entry|
          puts "#{Time.at(entry[:utc])} #{colored_tag(entry[:tag_id])} #{entry[:body]}#{' (done)' if entry[:done] > 0}"
        end
      end
    end

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
 
    def ago(days)
      (Date.today - days.to_i).to_time
    end
  end
end
