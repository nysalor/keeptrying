# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Keeptrying" do
  include FixtureHelpers

  let(:db_file) { "./kpt_test.sql" }
  let(:tags) { [:keep, :problem, :try] }
  let(:sentence) { Faker::Lorem.sentence }
  let(:table) { Keeptrying::Kpt.db[:entries] }
  let(:all_entries) { table.all }
  let(:past_time) { Time.local(2014, 4, 1, 10, 0, 0) }
  let(:recent_time) { Time.local(2014, 4, 3, 10, 0, 0) }

  describe "Kpt" do
    describe "initialize" do
      before do
        Keeptrying::Kpt.stub(:db_file).and_return(db_file)
        @kpt = Keeptrying::Kpt.new
      end

      after do
        table.truncate
      end

      after(:all) do
        File.delete db_file
      end

      it "dbが存在しない場合に作成されること" do
        File.should be_exists(db_file)
      end

      it "writeで内容が書き込まれること" do
        create_entry sentence
        all_entries.last[:body].should eq(sentence)
      end

      it "getで内容が取得できること" do
        create_entry sentence
        @kpt.query
        @kpt.get.last[:body].should eq(sentence)
      end

      it "doneで処理済みになること" do
        create_entry
        @kpt.query
        @kpt.done
        all_entries.last[:done].should eq(1)
      end

      it "タグを指定して内容が取得できること" do
        sentences = 5.times.map{ random_sentence }
        sentences[0, 3].each { |sentence| @kpt.write(:keep, sentence) }
        sentences[3, 2].each { |sentence| @kpt.write(:problem, sentence) }
        @kpt.query nil, nil, :keep
        @kpt.get.map{ |x| x[:body] }.should =~ sentences[0,3]
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

        it "getで指定した件数分の内容が取得できること" do
          @kpt.query
          @kpt.get(2).all.size.should eq(2)
        end

        it "時間を指定して内容が取得できること" do
          @kpt.query((past_time.to_i - 60), (recent_time.to_i - 60))
          @kpt.get.map{ |x| x[:body] }.should =~ @sentences[0, 3]
        end

        describe "processed entries" do
          before do
            @kpt.query((past_time.to_i - 60), (recent_time.to_i - 60))
            @kpt.done
          end

          it "期間を指定して処理済みになること" do
            all_entries.select{ |x| x[:done] > 0 }.
              map{ |x| x[:body] }.should =~ @sentences[0, 3]
          end

          it "処理済みの内容が取得されないこと" do
            kpt_after = Keeptrying::Kpt.new
            kpt_after.query
            kpt_after.get.map{ |x| x[:body] }.should =~ @sentences[3, 2]
          end

          it "処理済みを含めた内容を取得できること" do
            kpt_after = Keeptrying::Kpt.new
            kpt_after.query nil, nil, nil, true
            kpt_after.get.size.should eq(5)
          end
        end
      end
    end
  end
end
