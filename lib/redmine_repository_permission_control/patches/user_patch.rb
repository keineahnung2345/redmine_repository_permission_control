module RedmineRepositoryPermissionControl
  module Patches
    module UserPatch
      def self.included(base)
        base.prepend InstanceMethods
        base.class_eval do
          unloadable
          has_and_belongs_to_many :repositories, -> { order(:id).distinct }
        end
      end

      module InstanceMethods
        # Return true if the user is allowed to do access repository on a specific context
        # Context can be:
        # * a repository: returns true if user is allowed to access the repository
        # * an array of repositories: returns true if user is allowed on every repository
        def allowed_to_access_repository?(action, context, options={}, &block)
          if context && context.is_a?(Repository)
            # Admin users are authorized for anything else
            return true if admin?
      
            member = Member.find_by(:user_id => id, :project_id => context.project_id)
            member_inaccessible_repositories = MemberInaccessibleRepository.where(:member_id => member.id)
            inaccessible_repositories = Repository.where(:id => member_inaccessible_repositories.map(&:repository_id))
            inaccessible_repositories.nil? || (not (inaccessible_repositories.include? context))
          elsif context && context.is_a?(Array)
            if context.empty?
              false
            else
              # Authorize if user is authorized on every element of the array
              context.map {|repository| allowed_to_access_repository?(action, repository, options, &block)}.reduce(:&)
            end
          elsif context
            raise ArgumentError.new("#allowed_to_access_repository? context argument must be a Repository, an Array of repositories or nil")
          else
            false
          end
        end
      end
    end
  end
end
User.send(:include, RedmineRepositoryPermissionControl::Patches::UserPatch)
