class EmployeesController < ApplicationController

  def create
    byebug
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: employee.errors, status: :unprocessable_entity
    end
  end

  private

  def employee_params
    params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :doj, :salary, phone_numbers: [])
  end
end
