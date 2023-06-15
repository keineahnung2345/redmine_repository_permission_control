module RedmineRepositoryPermissionControl
  module Patches
    module RepositoryPatch
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :member_accessible_repositories, :dependent => :destroy
          has_many :members, lambda {distinct}, :through => :member_accessible_repositories, :foreign_key => :accessible_member_id

          alias_attribute :accessible_member_ids, :member_ids
        end
        base.prepend InstanceMethods
      end

      module InstanceMethods
        def accessible_member_ids=(arg)
          ids = (arg || []).collect(&:to_i) - [0]
          # Add new accessible_repositories
          new_ids = ids - member_accessible_repositories.where(:repository => self).pluck(:member_id)
          new_ids.each do |id|
            member_accessible_repositories << MemberAccessibleRepository.new(:member_id => id, :repository => self)
          end
          # Remove accessible_repositories (Rails' #accessible_repository_ids= will not trigger MemberRole#on_destroy)
          member_accessible_repositories_to_destroy = member_accessible_repositories.select {|mr| !ids.include?(mr.member_id)}
          if member_accessible_repositories_to_destroy.any?
            member_accessible_repositories_to_destroy.each(&:destroy)
          end
          member_accessible_repositories.reload
          #super(ids)
        end
      end
    end
  end
end
Repository.send(:include, RedmineRepositoryPermissionControl::Patches::RepositoryPatch)
