class CreateMemberAccessibleRepositories < ActiveRecord::Migration[6.1]
  def change
    create_table :member_accessible_repositories do |t|
      t.column "member_id", :integer, :null => false
      t.column "repository_id", :integer, :null => false
      t.column "created_on", :timestamp
    end
  end
end
