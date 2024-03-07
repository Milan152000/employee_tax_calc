class Employee < ApplicationRecord
  validates_presence_of :employee_code, :first_name, :last_name, :phone_numbers, :doj, :salary
  validates :email, presence: true, uniqueness: true
end
