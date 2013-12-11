module Mongoid
  module Document
    module Mergeable
      
      # Merge a mongoid document into another.
      # A.merge!(B)
      def merge!(another_document)
        if another_document.nil?
          raise "Cannot merge a nil document."
        elsif self.class != another_document.class
          raise "Cannot merge two different models."
        elsif (!self.is_a? Mongoid::Document) || (!another_document.is_a? Mongoid::Document)
          raise "Can only merge mongoid documents."
        else 
          # let's merge these documents
          
          # A.merge!(B)
          #
          # We iterate on B attributes :
          another_document.attributes.keys.each do |key|
            self[key] = merge_attributes(self[key],another_document[key])           
          end
          
          # saving the A model
          self.save
          # delete the B model
          another_document.destroy 
        end
      end
      
      private
      
      def merge_attributes(a,b)
        if (a.class != nil) && (b.class != nil) && (a.class != b.class)
          raise "Can't merge different types : "+a.class+" and "+b.class
        else
          if (a != nil) && (a.is_a? Array) && (b.is_a? Array)
            # For an Array
            # we concat the values in B array at the end of the A Array (if it's not already included).
            b.each_with_index do |value, index|
              a[index] = merge_attributes(a[index],b[index]) 
            end
          elsif (a != nil) && (a.is_a? Hash) && (b.is_a? Hash)
            # For a Hash
            # recursive call
            b.keys.each do |key|
              a[key] = merge_attributes(a[key],b[key])
            end
          else
            # For Basic types (String, Double, Date, Boolean, etc...)
            # If the attribute is already defined in A and not nil, then we keep its value.
            # Else we copy the value of B into A
            if a.nil? && (b != nil)
              a = b
            end
          end
          
          return a 
        end
      end
    end
  end
end