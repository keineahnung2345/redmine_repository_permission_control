module RedmineRepositoryPermissionControl
  module Patches

    module MembersControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def update_accessible_repositories
          if params["member-#{@member.id}-membership".to_sym]
            accessible_repository_ids = (params["member-#{@member.id}-membership".to_sym][:repository_ids] || []).collect(&:to_i)
            @member.accessible_repository_ids = accessible_repository_ids
          end

          saved = @member.save
          respond_to do |format|
            format.html {redirect_to_settings_in_projects}
            format.js {render :update}
            format.api do
              if saved
                render_api_ok
              else
                render_validation_errors(@member)
              end
            end
          end
        end
      end
    end
  end
end

unless MembersController.included_modules.include?(RedmineRepositoryPermissionControl::Patches::MembersControllerPatch)
  MembersController.send(:include, RedmineRepositoryPermissionControl::Patches::MembersControllerPatch)
end
