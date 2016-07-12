class MachineTime < ActiveRecord::Base
validates :mo_no, uniqueness: true,:presence => { :message => " cannot be blank" }
belongs_to:order_summary
end
