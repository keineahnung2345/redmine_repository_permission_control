module RedmineRepositoryPermissionControl
  module Patches
    module MemberPatch
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :member_inaccessible_repositories, :dependent => :destroy
          has_many :repositories, lambda {distinct}, :through => :member_inaccessible_repositories, :foreign_key => :inaccessible_repository_id

          alias_attribute :inaccessible_repository_ids, :repository_ids
        end
        base.prepend InstanceMethods
      end

      module InstanceMethods
        def inaccessible_repository_ids=(arg)
          ids = (arg || []).collect(&:to_i)
          # Add new inaccessible_repositories
          ids.each do |id|
            member_inaccessible_repositories << MemberInaccessibleRepository.new(:repository_id => id, :member => self)
          end
          # Remove inaccessible_repositories (Rails' #inaccessible_repository_ids= will not trigger MemberRole#on_destroy)
          member_inaccessible_repositories_to_destroy = member_inaccessible_repositories.select {|mr| !ids.include?(mr.repository_id)}
          if member_inaccessible_repositories_to_destroy.any?
            member_inaccessible_repositories_to_destroy.each(&:destroy)
          end
          member_inaccessible_repositories.reload
          #super(ids)
        end
      end
    end
  end
end
Member.send(:include, RedmineRepositoryPermissionControl::Patches::MemberPatch)
