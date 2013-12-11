require "spec_helper"

# something needs this to avoid trace pollution...
I18n.enforce_available_locales = false

class Myclass
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Document::Mergeable
  
  field :a_string, :type => String
  field :another_string, :type => String
  field :a_number, :type => Float
  field :a_boolean, :type => Boolean
  field :array_simple_types, :type => Array
  field :array_hashes, :type => Array
  field :a_hash, :type => Hash
end

Mongoid.configure do |config|
  config.connect_to("merge_mongoid_spec")
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
    
    it "should keep all the A values when merging" do
      #keeping a backup version
      A_clone = @A.clone
      A_clone.created_at = @A.created_at
      A_clone.updated_at = @A.updated_at
      
      # just making sure we cloned correctly
      A_clone.a_string.should == @A.a_string
      A_clone.created_at.should == @A.created_at
      A_clone.updated_at.should == @A.updated_at
      
      #merging
      @A.merge! @B
      
      #values should be the same
      A_clone.a_string.should == @A.a_string
      A_clone.another_string.should == @A.another_string
      A_clone.a_number.should == @A.a_number
      A_clone.a_boolean.should == @A.a_boolean
      A_clone.array_simple_types.should == @A.array_simple_types
      A_clone.array_hashes.should == @A.array_hashes
      A_clone.a_hash.should == @A.a_hash
      
      #date_modified should be changed
      A_clone.updated_at.should_not == @A.updated_at
      
      #B should have been deleted
      expect { Myclass.find(@B._id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end
end
