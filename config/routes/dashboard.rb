constraints subdomain: "dashboard" do
  draw(:admin)

  devise_for :users, controllers: { registrations: "registrations" }

  resources :users, only: [] do
    collection do
      get :search_by_name
    end
  end

  resources :cohorts do
    member do
      get "canvas_highest_position_submission_count"
      get "canvas_point_total_most_recent"
      get "canvas_cumulative_points"
    end
    resources :canvas_gradebook_snapshots
    resources :discord_channels, only: [ :index, :show ] do
      resources :recurring_messages, only: [ :create, :edit, :update, :destroy ]
    end
    resources :enrollments, module: :cohort do
      member do
        get "overview"
        get "snapshot"
      end
      collection do
        get "search"
      end
    end
    resources :feedback_reports, module: :cohort do
      member do
        post :send_report
      end
      collection do
        post :batch, action: :batch_create
      end
    end
    resources :impressions, module: :cohort do
      collection do
        get :search
      end
    end
    resources :piazza_activity_reports
    resources :attendances
  end

  resources :impressions do
    get :search, to: "impressions#search", on: :collection
  end

  root "dashboard#index", as: "dashboard_root"
end
