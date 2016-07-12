class Reground < ActiveRecord::Base
validates_uniqueness_of :reground_list, :case_sensitive => false
validates :reground_list, :presence => true
def self.search(search)
   where("reground_list LIKE '%#{search}%'" )
   end
end
