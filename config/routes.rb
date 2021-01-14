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
        get  :uptoday
        get  :to_approves
        post  :update_approves
        get :be_deletes
      end
    end

    resources :videos do
      collection do
        get  :update_status
        post  :update_approve
        get  :approved_list
        get  :to_approve
        get  :uptoday
        get  :to_approves
        post  :update_approves
        get :be_deletes
      end
    end

    resources :medial_spiders do
      collection do
        get  :update_status
      end
    end

    resources :medial_caches do
      collection do
        get  :update_status
      end
    end

    resources :classifications do
      collection do
        get  :update_status
      end
    end

    resources :categories do
      collection do
        get  :update_status
      end
    end

    resources :spider_targets do
      collection do
        get  :update_status
      end
    end

    resources :tags do
      collection do
        get  :update_status
      end
    end

    resources :click_logs, only: [:index] do
      collection do
        get :uptoday
      end
    end

  end

  resources :home do
    collection do 
      get :category_list
      get :visit_log
      get :location_source
      post :youtube_catch
      get :youtube_share
    end
  end

  resources :school do
    collection do
      get :category_list
      get :location_source
    end
  end


  root to: 'admin/employees#index'
  devise_for :employees, path: "admin", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', sign_up: 'cmon_let_me_in' }, controllers: { sessions: "admin/sessions", passwords: "admin/passwords"}

end
