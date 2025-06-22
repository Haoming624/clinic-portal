class Patient < ApplicationRecord
  belongs_to :updated_by_user, class_name: "User", optional: true

  enum :status, {
    active: "active",
    discharged: "discharged",
    deceased: "deceased"
  }

  validates :status, inclusion: { in: statuses.keys }
end
