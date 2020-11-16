module TapasEngine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    scope :recent, -> { order(created_at: :desc) }
    
    scope :today, -> { where(created_at: Time.zone.now.all_day) }
    scope :yesterday, -> { where(created_at: Time.zone.yesterday.all_day) }
    
    scope :this_week, -> { where(created_at: Time.zone.now.all_week) }
    scope :last_week, -> { where(created_at: (Time.zone.now - 1.week).all_week) }

    scope :last_7_days, -> { where(created_at: (Time.zone.now - 1.week).beginning_of_day..Time.zone.now) }
    
    scope :this_month, -> { where(created_at: Time.zone.now.all_month) }
    scope :last_month, -> { where(created_at: (Time.zone.now - 1.month).all_month) }
    
    scope :this_year, -> { where(created_at: Time.zone.now.all_year) }
    scope :last_year, -> { where(created_at: (Time.zone.now - 1.year).all_year) }

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
