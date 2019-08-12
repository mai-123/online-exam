class ResultAnswer < ApplicationRecord
  scope :by_result, ->(result) { where result: result }

  belongs_to :answer
  belongs_to :result

  validates :answer, presence: true
  validates :result, presence: true
end
