class Patient < ApplicationRecord
  belongs_to :updated_by_user, class_name: "User", optional: true

  enum :status, {
    active: "active",
    discharged: "discharged",
    deceased: "deceased"
  }

  validates :status, inclusion: { in: statuses.keys }

  # Soft delete functionality
  scope :active_records, -> { where(deleted_at: nil) }
  scope :deleted_records, -> { where.not(deleted_at: nil) }

  # Override default scope to only show non-deleted records
  default_scope { where(deleted_at: nil) }

  # Soft delete method
  def soft_delete
    update(deleted_at: Time.current)
  end

  # Restore method
  def restore
    update(deleted_at: nil)
  end

  # Check if record is soft deleted
  def soft_deleted?
    deleted_at.present?
  end

  # Override destroy to use soft delete
  def destroy
    soft_delete
  end

  # Hard delete method (use with caution)
  def hard_delete
    super
  end
end
