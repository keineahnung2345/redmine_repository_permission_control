desc <<-END_DESC
Seed repository permission data
Example:
  rake redmine:redmine_repository_permission_control:seed RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

namespace :redmine do
  namespace :redmine_repository_permission_control do
    task :seed => :environment do
      puts "Seeding initial member accessible repository values."
      data = []
      for project in Project.all
        Rails.logger.info "seeding #{project.identifier}"
        for repository in project.repositories
          for member in project.members
            data.append({:repository_id => repository.id, :member_id => member.id})
          end
        end
      end
      Rails.logger.info "writing into database..."
      MemberAccessibleRepository.create!(data)
    end
  end
end
