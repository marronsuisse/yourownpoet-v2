class Verse < ActiveRecord::Base
  validates :line_one, :line_two, :line_three, :line_four, :line_five, presence: true
  validates_inclusion_of :sex, in: 0..2
  #belongs_to :category
end