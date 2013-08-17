JjpLite::Application.routes.draw do

  # devise!
  devise_for :users, :path => 'm/user', :skip => [ :displayqr ] do
    get 'm/user/checkga'   => 'devise/checkga#show',   :as => 'user_checkga'
    put 'm/user/checkga'   => 'devise/checkga#update', :as => 'user_checkga'
  end
  
  # management section
  namespace :admin, :path => 'm' do
    root :to => 'dashboard#index'
    
    # auto-hooks
    resources :articles, :categories, :pages, :media, :id => /\d+/ do
      member do
        get   'embed'
        get   'preview'
        get   'select'
      end
      collection do
        match 'search'
        get   'choose'
      end
    end
    
    # various password shenanigans
    match 'first_time'  => 'password#first_time', :as => 'first_login', :via => [:get, :put]
    match '2fa/disable' => 'password#twofa_disable', :as => 'twofa_disable', :via => [:post]
    match '2fa'         => 'password#twofa',      :as => 'twofa',  :via => [:get, :put]
    get   'password'    => 'password#edit',       :as => 'change_password'
    put   'password'    => 'password#update',     :as => 'change_password'
    
    # dashboard feeds
    get   'feeds/articles'  => 'dashboard#latest_articles', :as => 'articles_feed'
    get   'feeds/drafts'    => 'dashboard#drafts',          :as => 'drafts_feed'
    
    #article stuffs;
    post  'articles/:id/publish'    => 'articles#publish',    :as => 'publish_article'
    post  'articles/:id/unpublish'  => 'articles#unpublish',  :as => 'unpublish_article'
  end
  
  # responsive media stuff
  get 'media/ping/:size'          => 'media#ping'
  get 'media/:id(/:size)'         => 'media#view',      :constraints => { :id => /\d+/ }, :as => 'media'
  
  # Blog routes
  get 'articles/category/:slug'   => 'articles#list',   :constraints => { :slug => /[a-z0-9\-_]+/i }, :as => '_category'
  get 'articles/:slug'            => 'articles#show',   :constraints => { :slug => /\d{4}\/\d{2}\/([0-9a-z\-_]+)/i }, :as => '_article'
  get 'articles(/:year(/:month))' => 'articles#list',   :constraints => { :year => /\d{4}/, :month => /[01][0-9]/ }, :as => 'articles'
  
  # failthru to pages
  get ':slug' => 'page#show', :constraints => { :slug => /[a-z0-9\-_\/]+/i }, :as => '_page'
  
  # home page
  root :to => 'articles#index'
end
