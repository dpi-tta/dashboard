class CreateFeedbackReports < ActiveRecord::Migration[7.0]
  def change
    create_table :feedback_reports, id: :uuid do |t|
      t.references :enrollment, null: false, foreign_key: true, type: :uuid
      t.references :canvas_gradebook_snapshot, null: false, foreign_key: true, type: :uuid
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :message, null: false
      t.boolean :sent, default: false
      t.string :error_message

      t.timestamps
    end

    add_index :feedback_reports, [ :enrollment_id, :canvas_gradebook_snapshot_id, :start_date, :end_date ],
              unique: true, name: 'index_feedback_reports_on_unique_constraint'
  end
end
