# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Keeptrying" do
  let(:db_file) { "./kpt_test.sql" }
  let(:tags) { [:keep, :problem, :try] }
  let(:sentence) { Faker::Lorem.sentence }
  let(:table) { Keeptrying::Kpt.db[:entries] }
  let(:all_entries) { table.all }
  let(:three_sentences) { 3.times.map{ Faker::Lorem.sentence } }
  let(:five_sentences) { 5.times.map{ Faker::Lorem.sentence } }
  let(:past) { Time.local(2014, 4, 1, 10, 0, 0) }
  let(:recent) { Time.local(2014, 4, 3, 10, 0, 0) }

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
        @kpt.write :keep, sentence
        all_entries.last[:body].should eq(sentence)
      end

      it "getで内容が取得できること" do
        @kpt.write :problem, sentence
        @kpt.query
        @kpt.get.last[:body].should eq(sentence)
      end

      it "getで指定した件数分の内容が取得できること" do
        20.times.each do |idx|
          tag = tags.sample
          @kpt.write tag, sentence
        end
        @kpt.query
        @kpt.get(5).all.size.should eq(5)
      end

      it "時間を指定して内容が取得できること" do
        Timecop.freeze(past) do
          three_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        Timecop.freeze(recent) do
          five_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        @kpt.query((past.to_i - 60), (recent.to_i - 60))
        @kpt.get.map{ |x| x[:body] }.should =~ three_sentences
      end

      it "タグを指定して内容が取得できること" do
        three_sentences.each do |s|
          @kpt.write :keep, s
        end
        five_sentences.each do |s|
          @kpt.write :problem, s
        end
        @kpt.query nil, nil, :keep
        @kpt.get.map{ |x| x[:body] }.should =~ three_sentences
      end

      it "doneで処理済みになること" do
        @kpt.write :keep, sentence
        @kpt.query
        @kpt.done
        all_entries.last[:done].should eq(1)
      end

      it "期間を指定して処理済みになること" do
        Timecop.freeze(past) do
          three_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        Timecop.freeze(recent) do
          five_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        @kpt.query((past.to_i - 60), (recent.to_i - 60))
        @kpt.done
        all_entries.select{ |x| x[:done] > 0 }.
          map{ |x| x[:body] }.should =~ three_sentences
      end

      it "処理済みの内容が取得されないこと" do
        Timecop.freeze(past) do
          three_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        Timecop.freeze(recent) do
          five_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        @kpt.query((past.to_i - 60), (recent.to_i - 60))
        @kpt.done

        @kpt_after = Keeptrying::Kpt.new
        @kpt_after.query
        @kpt_after.get.map{ |x| x[:body] }.should =~ five_sentences
      end

      it "処理済みの内容を取得できること" do
        Timecop.freeze(past) do
          three_sentences.each do |s|
            tag = [:keep, :problem, :try].sample
            @kpt.write tag, s
          end
        end

        @kpt.query
        @kpt.done

        @kpt_after = Keeptrying::Kpt.new
        @kpt_after.query nil, nil, nil, true
        @kpt_after.get.map{ |x| x[:body] }.should =~ three_sentences
      end
    end
  end
end
