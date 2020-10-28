module TapasEngine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    # include BaseModelConcern

    scope :recent, -> { order(created_at: :desc) }
    scope :recent_published, -> { order(published_at: :desc) }

    scope :by_created_at, lambda { |start_at = nil, end_at = nil|
      if start_at.present? || end_at.present?
        rel = self
        rel = rel.where('created_at >= ?', start_at) if start_at.present?
        rel = rel.where('created_at <= ?', end_at) if end_at.present?
        rel
      end
    }
  end
end
