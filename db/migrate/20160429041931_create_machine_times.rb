class CreateMachineTimes < ActiveRecord::Migration
  def change
    create_table :machine_times do |t|
      t.string :mo_no
      t.string :cycle_time

      t.timestamps null: false
    end
  end
end
