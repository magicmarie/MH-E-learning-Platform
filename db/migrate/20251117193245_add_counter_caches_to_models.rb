class AddCounterCachesToModels < ActiveRecord::Migration[8.0]
  def change
    # Counter caches for Course
    add_column :courses, :enrollments_count, :integer, default: 0, null: false
    add_column :courses, :assignments_count, :integer, default: 0, null: false

    # Counter caches for Assignment
    add_column :assignments, :assessments_count, :integer, default: 0, null: false
    add_column :assignments, :submissions_count, :integer, default: 0, null: false
    add_column :assignments, :assessed_count, :integer, default: 0, null: false

    # Total score cache for Enrollment
    add_column :enrollments, :total_score, :decimal, precision: 10, scale: 2, default: 0.0, null: false

    # Backfill existing data
    reversible do |dir|
      dir.up do
        # Update course counters
        Course.find_each do |course|
          Course.reset_counters(course.id, :enrollments, :assignments)
        end

        # Update assignment counters
        Assignment.find_each do |assignment|
          Assignment.reset_counters(assignment.id, :assessments)
          assignment.update_columns(
            submissions_count: assignment.assessments.where.not(submitted_at: nil).count,
            assessed_count: assignment.assessments.where.not(assessed_on: nil).count
          )
        end

        # Update enrollment total scores
        Enrollment.find_each do |enrollment|
          enrollment.update_column(:total_score, enrollment.assessments.sum(:score))
        end
      end
    end
  end
end
