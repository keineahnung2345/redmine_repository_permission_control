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
end
