module RedmineRepositoryPermissionControl
  module Patches
    module RepositoriesControllerPatch
      def self.included(base)
        base.class_eval do
          before_action :authorize_repository

          prepend InstanceMethods
        end #base
      end #self

      module InstanceMethods
        def check_is_accessible(repo)
          return false if repo.nil?
          member = Member.find_by(:user_id => User.current.id, :project_id => @project.id)
          (not (MemberInaccessibleRepository.where(:member_id => member.id).pluck(:repository_id).include? repo.id))
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
      end
    end #module
  end #module
end #module

unless RepositoriesController.included_modules.include?(RedmineRepositoryPermissionControl::Patches::RepositoriesControllerPatch)
  RepositoriesController.send(:include, RedmineRepositoryPermissionControl::Patches::RepositoriesControllerPatch)
end
