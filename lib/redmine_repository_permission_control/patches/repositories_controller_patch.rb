module RedmineRepositoryPermissionControl
  module Patches
    module RepositoriesControllerPatch
      def self.included(base)
        base.class_eval do
          before_action :find_project_by_project_id, :only => [:new, :create]
          before_action :build_new_repository_from_params, :only => [:new, :create]
          before_action :find_repository, :only => [:edit, :update, :destroy, :committers, :edit_accessible_members, :update_accessible_members]
          before_action :find_project_repository, :except => [:new, :create, :edit, :update, :destroy, :committers, :edit_accessible_members, :update_accessible_members]
          before_action :find_changeset, :only => [:revision, :add_related_issue, :remove_related_issue]

          # :authorize should be after :find_repository and :find_project_repository
          before_action :authorize
          before_action :authorize_repository, :except => [:new, :create]

          after_action :grant_creator_access, :only => [:create]

          prepend InstanceMethods
        end #base
      end #self

      module InstanceMethods
        def check_is_accessible(repo)
          return false if repo.nil?
          return true if User.current.admin?
          member = Member.find_by(:user_id => User.current.id, :project_id => @project.id)
          MemberAccessibleRepository.where(:member_id => member.id).pluck(:repository_id).include? repo.id
        end

        def find_repositories
            @repositories = @project.repositories
            @repositories = @repositories.select {|repo| check_is_accessible(repo)}
        end

        # filter @repositories
        def show
          @repository.fetch_changesets if @project.active? && Setting.autofetch_changesets? && @path.empty?
      
          @entries = @repository.entries(@path, @rev)
          @changeset = @repository.find_changeset_by_name(@rev)
          if request.xhr?
            @entries ? render(:partial => 'dir_list_content') : head(200)
          else
            (show_error_not_found; return) unless @entries
            @changesets = @repository.latest_changesets(@path, @rev)
            @properties = @repository.properties(@path, @rev)
            find_repositories
            render :action => 'show'
          end
        end

        # choose visible @repository
        def find_project_repository
          @project = Project.find(params[:id])
          if params[:repository_id].present?
            @repository = @project.repositories.find_by_identifier_param(params[:repository_id])
          else
            if check_is_accessible(@project.repository)
              @repository = @project.repository
            else
              find_repositories
              @repository = @repositories.first
            end
          end
          (render_404; return false) unless @repository
          @path = params[:path].is_a?(Array) ? params[:path].join('/') : params[:path].to_s
      
          @rev = params[:rev].to_s.strip.presence || @repository.default_branch
          raise InvalidRevisionParam unless valid_name?(@rev)
      
          @rev_to = params[:rev_to].to_s.strip.presence
          raise InvalidRevisionParam unless valid_name?(@rev_to)
        rescue ActiveRecord::RecordNotFound
          render_404
        rescue InvalidRevisionParam
          show_error_not_found
        end

        def update_accessible_members
          if params["repository-#{@repository.id}-membership".to_sym]
            accessible_member_ids = (params["repository-#{@repository.id}-membership".to_sym][:member_ids] || []).collect(&:to_i)
            @repository.accessible_member_ids = accessible_member_ids
          end

          saved = @repository.save
          respond_to do |format|
            format.html {redirect_to_settings_in_projects}
            format.js
            format.api do
              if saved
                render_api_ok
              else
                render_validation_errors(@repository)
              end
            end
          end
        end

        def grant_creator_access
          mar = MemberAccessibleRepository.new(:member_id => @project.members.where(:user_id => User.current.id)[0].id, :repository => @repository)
          mar.save!
        end
      end
    end #module
  end #module
end #module

unless RepositoriesController.included_modules.include?(RedmineRepositoryPermissionControl::Patches::RepositoriesControllerPatch)
  RepositoriesController.send(:include, RedmineRepositoryPermissionControl::Patches::RepositoriesControllerPatch)
end
