class AddCostPerPieceToLabour < ActiveRecord::Migration
  def change
    add_column :labours, :cost_per_piece, :string
  end
end
