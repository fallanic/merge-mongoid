require "spec_helper"

class Myclass
  include Mongoid::Document
  include Mongoid::Document::Mergeable
  
  field :a_string, :type => String
  field :another_string, :type => String
  field :a_number, :type => Float
  field :a_boolean, :type => Boolean
  field :array_simple_types, :type => Array
  field :array_hashes, :type => Array
  field :a_hash, :type => Hash
end

FactoryGirl.define do 
  
  factory :myclass do
    _id { BSON::ObjectId.new.to_s }
    sequence(:a_string) { |n| "A_String_#{n}" }
    sequence(:another_string) { |n| "Another_string_#{n}" }
    sequence(:a_number) { |n| n}
    sequence(:a_boolean) { true}
    array_simple_types{["an","array","with","elements"]}
    array_hashes{[{
      "id" => BSON::ObjectId.new.to_s,
      "attribute" => "yes there is one"
    },{
      "id" => BSON::ObjectId.new.to_s,
      "attribute" => "a value here too"
    },{
      "id" => BSON::ObjectId.new.to_s,
      "other_attribute" => "hey"
    }]}
    a_hash{
      {
        "_id" => BSON::ObjectId.new.to_s,
        "a string" => "hello",
        "a number" => 12
      }
    }
  end
end

describe Mongoid::Document::Mergeable do
  context "Merging of simple types" do
    before(:each) do
      @A = FactoryGirl.build(:myclass)
      @B = FactoryGirl.build(:myclass)
    end

    it "should create two different objects" do
      @A._id.should_not == @B._id
    end
    
    it "should create objects with a 'merge!' method" do
      @A.methods.should include :merge!
    end
  end
end
