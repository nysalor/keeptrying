# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Keeptrying" do
  let(:db_file) { "./kpt_test.sql" }

  describe "Kpt" do
    describe "initialize" do
      it "dbが存在しない場合に作成されること" do
        Keeptrying::Kpt.stub(:db_file).and_return(db_file)
        Keeptrying::Kpt.new
        File.should be_exists(db_file)
        File.delete db_file
      end
    end
  end
end 
