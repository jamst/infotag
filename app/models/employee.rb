class Employee < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable#, :trackable, :validatable
  
  has_and_belongs_to_many :roles, :join_table => :employees_roles
end
