class RenameEmployeeIdToEmployeeCode < ActiveRecord::Migration[6.1]
  def change
    rename_column :employees, :employee_id, :employee_code
  end
end
