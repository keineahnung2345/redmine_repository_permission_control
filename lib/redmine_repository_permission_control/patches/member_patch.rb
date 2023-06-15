module RedmineRepositoryPermissionControl
  module Patches
    module MemberPatch
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :member_accessible_repositories, :dependent => :destroy
          has_many :repositories, lambda {distinct}, :through => :member_accessible_repositories, :foreign_key => :accessible_repository_id

          alias_attribute :accessible_repository_ids, :repository_ids
        end
        base.prepend InstanceMethods
      end

      module InstanceMethods
        def accessible_repository_ids=(arg)
          ids = (arg || []).collect(&:to_i)
          # Add new accessible_repositories
          # FIXME: need to subtract existing ones?
          ids.each do |id|
            member_accessible_repositories << MemberAccessibleRepository.new(:repository_id => id, :member => self)
          end
          # Remove accessible_repositories (Rails' #accessible_repository_ids= will not trigger MemberRole#on_destroy)
          member_accessible_repositories_to_destroy = member_accessible_repositories.select {|mr| !ids.include?(mr.repository_id)}
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
Member.send(:include, RedmineRepositoryPermissionControl::Patches::MemberPatch)
