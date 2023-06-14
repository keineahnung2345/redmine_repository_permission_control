module RedmineRepositoryPermissionControl
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.class_eval do
          # Authorize the user for repository access
          def authorize_repository(ctrl = params[:controller], action = params[:action], global = false)
            allowed = User.current.allowed_to_access_repository?({:controller => ctrl, :action => action}, @repository || @repositories, :global => global)
            if allowed
              true
            else
              if @project && @project.archived?
                @archived_project = @project
                render_403 :message => :notice_not_authorized_archived_project
              elsif @project && !@project.allows_to?(:controller => ctrl, :action => action)
                # Project module is disabled
                render_403
              else
                deny_access
              end
            end
          end
        end #base
      end #self
    end #module
  end #module
end #module

unless ApplicationController.included_modules.include?(RedmineRepositoryPermissionControl::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineRepositoryPermissionControl::Patches::ApplicationControllerPatch)
end
