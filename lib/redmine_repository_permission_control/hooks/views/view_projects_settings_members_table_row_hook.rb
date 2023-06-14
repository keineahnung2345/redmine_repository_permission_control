module RedmineRepositoryPermissionControl
  module Hooks
    module Views
      class ViewProjectsSettingsMembersTableRowHook < Redmine::Hook::ViewListener
        render_on :view_projects_settings_members_table_row, partial: 'settings/inaccessible_repositories_table_row'
      end
    end
  end
end
