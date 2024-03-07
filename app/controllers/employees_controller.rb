class EmployeesController < ApplicationController

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: employee.errors, status: :unprocessable_entity
    end
  end

  def tax_calculator
    employee = Employee.find(params[:employee_id])
    working_period = find_working_period(employee.doj) # Working duration of the employee in this financial year 
    yearly_salary = employee.salary * 12 # Yearly salary for whole year (1st April - 31st March)
    total_salary = (working_period[:months] + (working_period[:days].to_f/30)) * employee.salary # Salary earned by the employee for the time he/she worked

    # Below logic is to count yearly Tax and additional cess deduction
    yearly_tax_deduction = case yearly_salary
                when 0..250000
                  0
                when 250001..500000
                  (yearly_salary - 250000) * 0.05
                when 500001..1000000
                  12500 + (yearly_salary - 500000) * 0.1
                else
                  12500 + 50000 + (yearly_salary - 1000000) * 0.2
                end
    yearly_additional_cess = (yearly_salary > 2500000) ? ((yearly_salary - 2500000) * 0.02) : 0

    # Below logic is to count the Monthly Tax deduction
    monthly_tax_deduction = yearly_tax_deduction.to_f/12 # Tax to be deducted monthly
    monthly_additional_cess = yearly_additional_cess.to_f/12 # Additional cess to be deducted monthly

    # Total tax deducted for the time employee worked.
    employee_tax_deduction = (working_period[:months] + working_period[:days].to_f/30) * monthly_tax_deduction
    employee_additional_cess = (working_period[:months] + working_period[:days].to_f/30) * monthly_additional_cess
    
    tax_info = {
      employee_code: employee.employee_code,
      first_name: employee.first_name,
      last_name: employee.last_name,
      yearly_salary: yearly_salary,
      yearly_tax_deduction: yearly_tax_deduction,
      yearly_additional_cess: yearly_additional_cess,
      total_earned_salary: total_salary,
      total_tax_deducted: employee_tax_deduction,
      total_additional_cess: employee_additional_cess,
    }

    render json: tax_info
  end

  def find_working_period(joining_date)
    if joining_date.month <= 3
      months = 3 - joining_date.month
      days = 31 - joining_date.day
    else
      months = 15 - joining_date.month
      days = 31 - joining_date.day
    end
    return {months: months, days: days}
  end

  private

  def employee_params
    params.require(:employee).permit(:employee_code, :first_name, :last_name, :email, :doj, :salary, phone_numbers: [])
  end
end
