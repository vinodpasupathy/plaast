# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160603061230) do

  create_table "admins", force: :cascade do |t|
    t.string   "order_party",    limit: 255
    t.string   "purchase_party", limit: 255
    t.string   "chem",           limit: 255
    t.string   "chem_typ",       limit: 255
    t.string   "ra_material",    limit: 255
    t.string   "mouldno",        limit: 255
    t.string   "finishgoods",    limit: 255
    t.string   "mach_use",       limit: 255
    t.string   "reason_idle",    limit: 255
    t.string   "work_nature",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "chemical_types", force: :cascade do |t|
    t.string   "chemical_type_list", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "chemicals", force: :cascade do |t|
    t.string   "chemical_list", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "color_issues", force: :cascade do |t|
    t.string   "color_issue_list", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "costs", force: :cascade do |t|
    t.string   "cost_per_unit", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "finished_goods_names", force: :cascade do |t|
    t.string   "finished_goods_name_list", limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "finisheds", force: :cascade do |t|
    t.string   "nett_available",       limit: 255
    t.string   "freight",              limit: 255
    t.string   "overheads",            limit: 255
    t.string   "packing_materials",    limit: 255
    t.string   "spares_used",          limit: 255
    t.string   "spares_cost",          limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "production_report_id", limit: 4
    t.integer  "labour_id",            limit: 4
    t.string   "created_by",           limit: 255
    t.string   "updated_by",           limit: 255
    t.datetime "deleted_at"
    t.string   "shift",                limit: 255
    t.string   "issue_date",           limit: 255
    t.integer  "order_no",             limit: 4
    t.integer  "issue_slip_no",        limit: 4
  end

  add_index "finisheds", ["labour_id"], name: "index_finisheds_on_labour_id", using: :btree
  add_index "finisheds", ["production_report_id"], name: "index_finisheds_on_production_report_id", using: :btree

  create_table "insert_materials", force: :cascade do |t|
    t.string   "insert_material_list", limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "ireturns", force: :cascade do |t|
    t.string   "grn_no",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "issue_id",      limit: 4
    t.datetime "deleted_at"
    t.string   "shift",         limit: 255
    t.string   "issue_date",    limit: 255
    t.string   "created_by",    limit: 255
    t.string   "updated_by",    limit: 255
    t.integer  "order_no",      limit: 4
    t.integer  "issue_slip_no", limit: 4
  end

  add_index "ireturns", ["issue_id"], name: "index_ireturns_on_issue_id", using: :btree

  create_table "issues", force: :cascade do |t|
    t.string   "order_date",         limit: 255
    t.string   "rm_qty",             limit: 255
    t.string   "che_qty",            limit: 255
    t.string   "rg_qty",             limit: 255
    t.string   "party",              limit: 255
    t.string   "issue_date",         limit: 255
    t.string   "machine_no",         limit: 255
    t.string   "shift",              limit: 255
    t.string   "chem_qty",           limit: 255
    t.string   "chem_qty_return",    limit: 255
    t.string   "chem_rate",          limit: 255
    t.string   "generated",          limit: 255
    t.string   "lumps",              limit: 255
    t.string   "qty_after_rg",       limit: 255
    t.string   "rm_issues",          limit: 255
    t.string   "rm_consume",         limit: 255
    t.string   "rm_qty_return",      limit: 255
    t.string   "rm_rate",            limit: 255
    t.string   "rg_material_issues", limit: 255
    t.string   "rg_qty_issued",      limit: 255
    t.string   "rg_qty_return",      limit: 255
    t.string   "rg_consume",         limit: 255
    t.string   "rg_rate",            limit: 255
    t.string   "rm_cost",            limit: 255
    t.string   "che_cost",           limit: 255
    t.string   "rg_cost",            limit: 255
    t.string   "consolidated_qty",   limit: 255
    t.string   "consolidated_cost",  limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "chemicals_type",     limit: 255
    t.datetime "deleted_at"
    t.string   "created_by",         limit: 255
    t.string   "updated_by",         limit: 255
    t.integer  "order_summary_id",   limit: 4
    t.string   "chemicals",          limit: 255
    t.string   "total_kgs",          limit: 255
    t.string   "bush_mat_issues",    limit: 255
    t.string   "bush_qty_issued",    limit: 255
    t.string   "bush_qty_return",    limit: 255
    t.string   "bush_rate",          limit: 255
    t.string   "bush_cost",          limit: 255
    t.string   "insert_material",    limit: 255
    t.string   "bush_qty",           limit: 255
    t.string   "rm_mat_qty",         limit: 255
    t.string   "ferul_mat_issues",   limit: 255
    t.string   "ferul_qty_issued",   limit: 255
    t.string   "ferul_qty_return",   limit: 255
    t.string   "ferul_rate",         limit: 255
    t.string   "ferul_cost",         limit: 255
    t.string   "ferul_qty",          limit: 255
    t.string   "total_iss",          limit: 255
    t.integer  "order_no",           limit: 4
    t.integer  "issue_slip_no",      limit: 4
  end

  add_index "issues", ["deleted_at"], name: "index_issues_on_deleted_at", using: :btree
  add_index "issues", ["order_summary_id"], name: "index_issues_on_order_summary_id", using: :btree

  create_table "labours", force: :cascade do |t|
    t.string   "nature",                     limit: 255
    t.string   "difference",                 limit: 255
    t.string   "rate_per_person",            limit: 255
    t.string   "efficiency",                 limit: 255
    t.string   "cost_per_shift",             limit: 255
    t.string   "no_of_hrs_idle",             limit: 255
    t.string   "no_of_mins_idle",            limit: 255
    t.string   "reasons_for_idle",           limit: 255
    t.string   "no_of_cavity",               limit: 255
    t.string   "cycle_time",                 limit: 255
    t.string   "no_of_persons",              limit: 255
    t.string   "working_hrs",                limit: 255
    t.string   "supervisor_name",            limit: 255
    t.string   "other_work",                 limit: 255
    t.string   "expected_production",        limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "mould",                      limit: 255
    t.datetime "deleted_at"
    t.integer  "issue_id",                   limit: 4
    t.integer  "production_report_id",       limit: 4
    t.string   "total_no_of_items_produced", limit: 255
    t.string   "created_by",                 limit: 255
    t.string   "updated_by",                 limit: 255
    t.string   "date",                       limit: 255
    t.string   "spares_name",                limit: 255
    t.string   "spares_cost",                limit: 255
    t.string   "remarks",                    limit: 255
    t.string   "shift",                      limit: 255
    t.string   "issue_date",                 limit: 255
    t.string   "machine_no",                 limit: 255
    t.integer  "order_summary_id",           limit: 4
    t.string   "pro_time",                   limit: 255
    t.integer  "order_no",                   limit: 4
    t.integer  "issue_slip_no",              limit: 4
    t.string   "cost_per_piece",             limit: 255
  end

  add_index "labours", ["deleted_at"], name: "index_labours_on_deleted_at", using: :btree
  add_index "labours", ["issue_id"], name: "index_labours_on_issue_id", using: :btree
  add_index "labours", ["order_summary_id"], name: "index_labours_on_order_summary_id", using: :btree
  add_index "labours", ["production_report_id"], name: "index_labours_on_production_report_id", using: :btree

  create_table "machine_maintenances", force: :cascade do |t|
    t.string   "mach_no",      limit: 255
    t.string   "type_of_prob", limit: 255
    t.string   "spare_name",   limit: 255
    t.string   "spare_cost",   limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "created_by",   limit: 255
    t.string   "updated_by",   limit: 255
    t.string   "date",         limit: 255
    t.datetime "deleted_at"
  end

  add_index "machine_maintenances", ["deleted_at"], name: "index_machine_maintenances_on_deleted_at", using: :btree

  create_table "machine_nos", force: :cascade do |t|
    t.string   "machine_no_list", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "machine_times", force: :cascade do |t|
    t.string   "mo_no",         limit: 255
    t.string   "cycle_time",    limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "machine_no_id", limit: 4
  end

  add_index "machine_times", ["machine_no_id"], name: "index_machine_times_on_machine_no_id", using: :btree

  create_table "machine_useds", force: :cascade do |t|
    t.string   "machine_used_list", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "mould_nos", force: :cascade do |t|
    t.string   "mould_no_list", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "name_of_supervisors", force: :cascade do |t|
    t.string   "name_of_supervisor_list", limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "nature_of_works", force: :cascade do |t|
    t.string   "nature_of_work_list", limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "order_summaries", force: :cascade do |t|
    t.string   "order_date",        limit: 255
    t.string   "scheduled_date",    limit: 255
    t.string   "party",             limit: 255
    t.string   "goods_finished",    limit: 255
    t.string   "nos",               limit: 255
    t.string   "ra_material",       limit: 255
    t.string   "rm_qty_per_item",   limit: 255
    t.string   "chemicals",         limit: 255
    t.string   "color_std",         limit: 255
    t.string   "chemical_qty",      limit: 255
    t.string   "total_kgs",         limit: 255
    t.string   "total_rm_kgs",      limit: 255
    t.string   "created_by",        limit: 255
    t.string   "updated_by",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "deleted_at"
    t.string   "reground_material", limit: 255
    t.string   "mould_no",          limit: 255
    t.string   "chel",              limit: 255
    t.string   "color_sd",          limit: 255
    t.integer  "order_no",          limit: 4
  end

  create_table "party_orders", force: :cascade do |t|
    t.string   "party_order_list", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "party_purchases", force: :cascade do |t|
    t.string   "party_purchase_list", limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "production_reports", force: :cascade do |t|
    t.string   "finished_goods_name",              limit: 255
    t.string   "total_no_of_items_produced",       limit: 255
    t.string   "weight_per_item",                  limit: 255
    t.string   "total_weight_consumed",            limit: 255
    t.string   "standard_weight",                  limit: 255
    t.string   "no_of_kgs_used_for_production",    limit: 255
    t.string   "variance",                         limit: 255
    t.string   "rejected_nos",                     limit: 255
    t.string   "rejected_nos_wt_for_re_grounding", limit: 255
    t.string   "lumps",                            limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "issue_id",                         limit: 4
    t.string   "order_date",                       limit: 255
    t.string   "shift",                            limit: 255
    t.string   "created_by",                       limit: 255
    t.string   "updated_by",                       limit: 255
    t.string   "date",                             limit: 255
    t.string   "party",                            limit: 255
    t.string   "consolidated_qty",                 limit: 255
    t.string   "selling_price",                    limit: 255
    t.string   "profit_loss",                      limit: 255
    t.string   "issue_date",                       limit: 255
    t.string   "machine_no",                       limit: 255
    t.datetime "deleted_at"
    t.string   "consolidated_cost",                limit: 255
    t.string   "realization_in_wt",                limit: 255
    t.string   "power_unit_reading",               limit: 255
    t.string   "power_unit_cost_kg",               limit: 255
    t.string   "power_unit_cost_piece",            limit: 255
    t.string   "cost_per_unit",                    limit: 255
    t.string   "realization_in_per",               limit: 255
    t.string   "reason_rejection",                 limit: 255
    t.integer  "order_no",                         limit: 4
    t.integer  "issue_slip_no",                    limit: 4
    t.text     "action_taken",                     limit: 65535
  end

  add_index "production_reports", ["issue_id"], name: "index_production_reports_on_issue_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.string   "item",             limit: 255
    t.string   "bill_value",       limit: 255
    t.string   "grn_no",           limit: 255
    t.string   "desc",             limit: 255
    t.string   "rate",             limit: 255
    t.string   "date",             limit: 255
    t.string   "debit",            limit: 255
    t.string   "party",            limit: 255
    t.string   "qty_accepted",     limit: 255
    t.string   "reasons",          limit: 255
    t.string   "trading_material", limit: 255
    t.string   "rejected",         limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "select_report",    limit: 255
    t.datetime "deleted_at"
    t.string   "qty_received",     limit: 255
    t.string   "created_by",       limit: 255
    t.string   "updated_by",       limit: 255
  end

  add_index "purchases", ["deleted_at"], name: "index_purchases_on_deleted_at", using: :btree

  create_table "raw_materials", force: :cascade do |t|
    t.string   "raw_material_list", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "reason_for_idle_times", force: :cascade do |t|
    t.string   "reason_for_idle_time_list", limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "regrounds", force: :cascade do |t|
    t.string   "reground_list", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rejection_reasons", force: :cascade do |t|
    t.string   "rejection_reason_list", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "returns", force: :cascade do |t|
    t.string   "grn_no",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "issue_id",   limit: 4
    t.string   "created_by", limit: 255
    t.string   "updated_by", limit: 255
  end

  add_index "returns", ["issue_id"], name: "index_returns_on_issue_id", using: :btree

  create_table "type_of_chemicals", force: :cascade do |t|
    t.string   "type_of_chemical_list", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "type_of_purchases", force: :cascade do |t|
    t.string   "purchase_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "password",              limit: 255
    t.string   "password_confirmation", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "role",                  limit: 255
  end

end
