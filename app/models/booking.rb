class Booking < ActiveRecord::Base
  attr_accessible :booking_date, :zip_code, :booking_details_attributes
  belongs_to :survey
  has_many :booking_details, dependent: :delete_all
  has_many :charges, through: :booking_details

  #before_save :commit_score!

  accepts_nested_attributes_for :booking_details, allow_destroy: true

  validates :survey_id, presence: true

  scope :interesting, where("score < 16 AND score > 2")
  scope :no_zip, where("zip_code = '00000' OR zip_code = '99999' OR zip_code IS NULL")
  scope :with_zip, where("zip_code > '00000' AND zip_code < '99999'")
  scope :with_ca_zip, where("zip_code BETWEEN '90001' AND '96162'")
  scope :zip, lambda { |zip| where("zip_code = ?", zip) }

  def commit_score!
    total_score = 0
    charges.each {|charge| total_score |= charge.score } # the | is bitwise OR
    self.score = total_score
  end

  def bucket
    if score.nil?
      commit_score!
      save!
    end
    s = score
    if s > 15
      "Disqualified"
    elsif s > 10
      "Co-Occurring"
    elsif s > 7
      "Substance Abuse"
    elsif s > 2
      "Mental Health"
    else
      "N/A"
    end
  end
end
