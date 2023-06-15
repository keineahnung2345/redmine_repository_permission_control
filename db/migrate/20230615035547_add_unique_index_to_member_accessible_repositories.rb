class AddUniqueIndexToMemberAccessibleRepositories < ActiveRecord::Migration[6.1]
  def change
    add_index :member_accessible_repositories, [:member_id, :repository_id], unique: true, name: "member_accessible_repository_index"
  end
end
