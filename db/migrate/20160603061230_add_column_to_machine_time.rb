class AddColumnToMachineTime < ActiveRecord::Migration
  def change
    add_reference :machine_times, :machine_no, index: true, foreign_key: true
  end
end
