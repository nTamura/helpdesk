class AddTicketReferencesToDepartments < ActiveRecord::Migration[5.0]
  def change
    add_reference :departments, :ticket, foreign_key: true
  end
end
