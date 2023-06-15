Redmine::Plugin.register :redmine_repository_permission_control do
  name 'Redmine Repository Permission Control plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  permission :edit_member_accessible_repositories, members: :edit_accessible_repositories
  permission :update_member_accessible_repositories, members: :update_accessible_repositories
  permission :edit_repository_accessible_members, repositories: :edit_accessible_members
  permission :update_repository_accessible_members, repositories: :update_accessible_members
end
