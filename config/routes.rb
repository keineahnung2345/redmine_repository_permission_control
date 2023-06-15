RedmineApp::Application.routes.draw do
  get 'members/:id/edit_accessible_repositories',
    :controller  => 'members',
    :action      => 'edit_accessible_repositories',
    :constraints => {:id => /\d+/, :format => /[^.]+/},
    :as          => "edit_member_accessible_repositories"
  put 'members/:id/update_accessible_repositories',
    :controller  => 'members',
    :action      => 'update_accessible_repositories',
    :constraints => {:id => /\d+/, :format => /[^.]+/},
    :as          => "update_member_accessible_repositories"
  get 'repositories/:id/edit_accessible_members',
    :controller  => 'repositories',
    :action      => 'edit_accessible_members',
    :constraints => {:id => /\d+/, :format => /[^.]+/},
    :as          => "edit_repository_accessible_members"
  put 'repositories/:id/update_accessible_members',
    :controller  => 'repositories',
    :action      => 'update_accessible_members',
    :constraints => {:id => /\d+/, :format => /[^.]+/},
    :as          => "update_repository_accessible_members"
end
