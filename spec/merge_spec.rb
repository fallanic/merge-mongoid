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
  context "Merging " do
    before(:each) do
      @A = FactoryGirl.build(:myclass)
      @B = FactoryGirl.build(:myclass)
      
      #keeping a backup version
      @A_clone = @A.clone
      @A_clone.created_at = @A.created_at
      @A_clone.updated_at = @A.updated_at
      
      # just making sure we cloned correctly
      @A_clone.a_string.should == @A.a_string
      @A_clone.created_at.should == @A.created_at
      @A_clone.updated_at.should == @A.updated_at
    end

    it "should create two different objects" do
      @A._id.should_not == @B._id
    end
    
    it "should create objects with a 'merge!' method" do
      @A.methods.should include :merge!
    end
    
    it "should keep all the A values when merging" do
      #merging
      @A.merge! @B
      
      #values should be the same
      @A_clone.a_string.should == @A.a_string
      @A_clone.another_string.should == @A.another_string
      @A_clone.a_number.should == @A.a_number
      @A_clone.a_boolean.should == @A.a_boolean
      @A_clone.array_simple_types.should == @A.array_simple_types #duplicate values are removed from the array, so it should be the original array
      @A_clone.a_hash.should == @A.a_hash
      
      #date_modified should be changed
      @A_clone.updated_at.should_not == @A.updated_at
      
      #B should have been deleted
      expect { Myclass.find(@B._id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
    it "should replace all A nil attributes by the B ones" do
      @A = Myclass.new
      @A.merge! @B
      
      # values should all be the B ones
      @A.a_string.should == @B.a_string
      @A.another_string.should == @B.another_string
      @A.a_number.should == @B.a_number
      @A.a_boolean.should == @B.a_boolean
      @A.array_simple_types.should == @B.array_simple_types
      @A.array_hashes.should == @B.array_hashes
      @A.a_hash.should == @B.a_hash
    end
    
    it "should merge arrays with simple types and remove duplicates" do
      @A.array_simple_types = ["a","totally","different","array"]
      @A.merge! @B
      
      #values should all be the B ones
      @A.array_simple_types.should == ["a","totally","different","array","an","with","elements"] #duplicate values are removed from the array
    end
    
    it "should merge the arrays of hashes and remove the duplicates if they exist" do
      #keeping the initial size
      initial_array_size = @A_clone.array_hashes.size
      
      @A.merge! @B
      #different ObjectIds so it is not merged, just concatenated at the end of the Array
      @A.array_hashes.size.should == (initial_array_size * 2)
      
      #keeping a backup version
      @A_clone2 = @A_clone.clone
      
      @A_clone.merge! @A_clone2
      # same object ids so the duplicates are removed
      @A_clone.array_hashes.size.should == initial_array_size
    end
    
    it "should merge the arrays of hashes with custom unique attribute and remove the duplicates if they exist" do
      initial_array_size = @A.array_hashes.size
        
      #keeping the initial size
      @B.array_hashes.push({"attribute" => "yes sir"})
      @A.merge!(@B,{"array_hashes" => "attribute"})
    
      @A.array_hashes.size.should == initial_array_size + 2 # Hash with "other_attribute" + hash with "attribute":"yes sir"
        
      #keeping a backup version
      @A_clone = @A.clone
      initial_array_size = @A_clone.array_hashes.size
      
      @A_clone.merge! @A
      # same object ids so the duplicates are removed
      @A_clone.array_hashes.size.should == initial_array_size
    end    
  end
end
