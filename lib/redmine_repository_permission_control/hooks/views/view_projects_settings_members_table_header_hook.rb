module RedmineRepositoryPermissionControl
  module Hooks
    module Views
      class ViewProjectsSettingsMembersTableHeaderHook < Redmine::Hook::ViewListener
        render_on :view_projects_settings_members_table_header, partial: 'settings/inaccessible_repositories_table_header'
      end
    end
  end
end

