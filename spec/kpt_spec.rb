# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Keeptrying" do
  include FixtureHelpers

  let(:db_file) { "./kpt_test.sql" }
  let(:tags) { [:keep, :problem, :try] }
  let(:tag) { tags.sample }
  let(:sentence) { Faker::Lorem.sentence }
  let(:table) { Keeptrying::Kpt.db[:entries] }
  let(:all_entries) { table.all }
  let(:past_time) { Time.local(2014, 4, 1, 10, 0, 0) }
  let(:recent_time) { Time.local(2014, 4, 3, 10, 0, 0) }
  let(:now) { Time.local(2014, 4, 4, 0, 0, 0) }
  let(:sentences) { 3.times.map { Faker::Lorem.sentence } }
  let(:query) { @kpt.query }

  before do
    Keeptrying::Kpt.stub(:db_file).and_return(db_file)
    @kpt = Keeptrying::Kpt.new
  end

  after(:all) do
    File.delete db_file
  end

  describe "Kpt" do
    after do
      table.truncate
    end

    it "dbが存在しない場合に作成されること" do
      File.should be_exists(db_file)
    end

    it "writeで内容が書き込まれること" do
      @kpt.write tag, sentence
      all_entries.last[:body].should eq(sentence)
    end

    it "内容が取得できること" do
      @kpt.write tag, sentence
      query.get.last[:body].should eq(sentence)
    end

    it "doneで処理済みになること" do
      create_entry
      query.done
      all_entries.last[:done].should eq(1)
    end

    it "タグを指定して内容が取得できること" do
      sentences = 5.times.map{ random_sentence }
      sentences[0, 3].each { |sentence| @kpt.write(:keep, sentence) }
      sentences[3, 2].each { |sentence| @kpt.write(:problem, sentence) }
      query.tag = :keep
      query.get.map{ |x| x[:body] }.should =~ sentences[0,3]
    end

    describe "collections by timeline" do
      before do
        @sentences = 5.times.map { random_sentence }
        Timecop.freeze(past_time) do
          @sentences[0, 3].each { |sentence| create_entry(sentence,) }
        end

        Timecop.freeze(recent_time) do
          @sentences[3, 2].each { |sentence| create_entry(sentence) }
        end
      end

      it "指定した件数分の内容が取得できること" do
        query.get(2).size.should eq(2)
      end

      it "時間を指定して内容が取得できること" do
        query.from = past_time.to_i - 60
        query.to = recent_time.to_i - 60
        query.get.map{ |x| x[:body] }.should =~ @sentences[0, 3]
      end

      describe "processed entries" do
        before do
          query.from = past_time.to_i - 60
          query.to = recent_time.to_i - 60
          query.done
        end

        it "期間を指定して処理済みになること" do
          all_entries.select{ |x| x[:done] > 0 }.
            map{ |x| x[:body] }.should =~ @sentences[0, 3]
        end

        it "処理済みの内容が取得されないこと" do
          new_query = @kpt.query
          new_query.get.map{ |x| x[:body] }.should =~ @sentences[3, 2]
        end

        it "処理済みを含めた内容を取得できること" do
          new_query = @kpt.query
          new_query.with_done = true
          new_query.get.size.should eq(5)
        end
      end
    end
  end

  describe "Command" do
    include FixtureHelpers
    include CaptureHelpers

    let(:command) { Keeptrying::Command }

    after do
      table.truncate
    end

    it "writeで内容が書き込まれること" do
      command.run ['write', "-#{tag[0]}", sentence]
      all_entries.last[:body].should eq(sentence)
    end

    it "showで内容が表示されること" do
      command.run ['write', "-#{tag[0]}", sentence]
      capture(:stdout) { command.run ['show'] }.should be_include(sentence)
    end

    it "showで特定のタグの内容が表示されること" do
      command.run ['write', "-k", sentences[0]]
      command.run ['write', "-p", sentences[1]]
      command.run ['write', "-t", sentences[2]]
      capture(:stdout) {
        command.run ['show', '-k']
      }.should be_include(sentences[0])
      capture(:stdout) {
        command.run ['show', '-k']
      }.should_not be_include(sentences[1])
    end

    it "実行後に検索条件が初期化されていること" do
      command.run ['write', "-k", sentences[0]]
      command.run ['write', "-p", sentences[1]]
      command.run ['write', "-t", sentences[2]]
      command.run ['show', '-k']
      capture(:stdout) {
        command.run ['show']
      }.should be_include(sentences[2])
    end

    describe "day range" do
      before do
        Timecop.freeze(past_time) do
          command.run ['write', "-k", sentences[0]]
          command.run ['write', "-p", sentences[1]]
        end
        Timecop.freeze(recent_time) do
          command.run ['write', "-t", sentences[2]]
        end
      end

      it "showで特定の日数以内の内容が表示されること" do
        Timecop.freeze(now) do
          capture(:stdout) {
            command.run ['show', '-t', 1]
          }.should be_include(sentences[2])
          capture(:stdout) {
            command.run ['show', '-k', 1]
          }.should_not be_include(sentences[0])
        end
      end

      it "doneで全ての内容が処理済みになること" do
        command.run ['done']
        all_entries.all? { |x| x[:done] == 1 }
      end

      it "showで処理済みの内容が表示されないこと" do
        command.run ['done']
        capture(:stdout) {
          command.run ['show', '-t', 1]
        }.should_not be_include(sentences[2])
        capture(:stdout) {
          command.run ['show', '-k', 1]
        }.should_not be_include(sentences[0])
      end

      it "doneで特定の日数以上の内容が処理済みになること" do
        Timecop.freeze(now) do
          command.run ['done', 1]
        end
        all_entries.first[:done].should eq(1)
      end

      it "allで処理済みの内容も取得できること" do
        command.run ['done']
        capture(:stdout) {
          command.run ['all']
        }.should_not be_include(sentences[0])
      end

      it "truncateで特定の日数以上の処理済みの内容が削除されること" do
        command.run ['done']
        Timecop.freeze(now) do
          command.run ['truncate', 1]
        end
        all_entries.count.should eq(1)
      end

      it "truncateで処理済みでない内容が削除されないこと" do
        Timecop.freeze(now) do
          command.run ['truncate', 1]
        end
        all_entries.count.should eq(3)
      end

      it "helpでヘルプが表示されること" do
        capture(:stdout) {
          command.run ['help']
        }.should be_include('usage')
      end
    end
  end
end
