class MachineMaintenance < ActiveRecord::Base
	acts_as_paranoid
def self.search(search)
where("mach_no LIKE '%#{search}%' OR type_of_prob LIKE '%#{search}%'" )
 end


end
