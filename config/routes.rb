Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :admin do
    root to: 'employees#desboart'
    resources :employees do
      collection do
        get  :forget_password
        post :forget_password
        get  :reset_mail
        get  :error_mail
        get  :add_roles
        post :save_roles
        get  :desboart
      end
    end

    resources :infos do
      collection do
        get  :update_status
        post  :update_approve
        get  :approved_list
        get  :to_approve
      end
    end

    resources :videos do
      collection do
        get  :update_status
        post  :update_approve
        get  :approved_list
        get  :to_approve
      end
    end

    resources :medial_spiders do
      collection do
        get  :update_status
      end
    end

  end

  resources :home

  root to: 'admin/employees#index'
  devise_for :employees, path: "admin", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', sign_up: 'cmon_let_me_in' }, controllers: { sessions: "admin/sessions", passwords: "admin/passwords"}

end
