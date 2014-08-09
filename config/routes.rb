JjpLite::Application.routes.draw do

  # devise!
  devise_for :users, :path => 'm/user'
  
  # management section
  namespace :admin, :path => 'm' do
    root :to => 'dashboard#index'
    
    # auto-hooks
    resources :articles, :categories, :pages, :media, :comments, :galleries, :id => /\d+/ do
      member do
        get   'embed'
        get   'preview'
      end
      collection do
        match 'search', :via => [ :get, :post ]
        get   'choose'
      end
    end
    
    # various password shenanigans
    match 'first_time'  => 'password#first_time', :as => 'first_login', :via => [:get, :put]
    match '2fa/disable' => 'password#twofa_disable', :as => 'twofa_disable', :via => [:post]
    match '2fa'         => 'password#twofa',      :as => 'twofa',  :via => [:get, :put]
    
    get   'password'    => 'password#edit',       :as => 'change_password'
    put   'password'    => 'password#update',     :as => 'save_password'
    
    # dashboard feeds
    get   'feeds/articles'  => 'dashboard#latest_articles', :as => 'articles_feed'
    get   'feeds/drafts'    => 'dashboard#drafts',          :as => 'drafts_feed'
    get   'feeds/comments'  => 'dashboard#comments',        :as => 'comments_feed'
    
    #article stuffs;
    post  'articles/:id/publish'    => 'articles#publish',    :as => 'publish_article'
    post  'articles/:id/unpublish'  => 'articles#unpublish',  :as => 'unpublish_article'
    
    # comment stuffs
    post  'comments/:id/screen/:state'  => 'comments#screen', :as => 'screen_comment', :constraints => { :id => /\d+/, :screen => /[0|1]/ }
    get   'article/:id/comments'    => 'comments#index',      :as => 'article_comments'
  end
  
  # responsive media stuff
  get 'media/ping/:size'          => 'media#ping'
  get 'media/:id(/:size)'         => 'media#view',      :constraints => { :id => /\d+/ }, :as => 'media'
  
  # Blog routes
  get 'articles/category/:slug'     => 'articles#list',     :constraints => { :slug => /[a-z0-9\-_]+/i }, :as => '_category'
  get 'articles(/:year(/:month))'     => 'articles#list',     :constraints => { :year => /\d{4}/, :month => /[01][0-9]/ }, :as => 'articles'
  constraints :slug => /\d{4}\/\d{2}\/([0-9a-z\-_]+)/i do
    get   'articles/*slug/comments/add' => 'comments#new',    :as => '_new_article_comment'
    get   'articles/*slug/comments'     => 'comments#index',  :as => '_article_comments'
    post  'articles/*slug/comments'     => 'comments#create'
      
    get 'articles/*slug'                => 'articles#show',     :as => '_article'
  end
  
  # more comment routes
  constraints :id => /\d+/ do
    get     'comments/:id'                => 'comments#show',   :as => 'comment'
    patch   'comments/:id'                => 'comments#update'
    delete  'comments/:id'                => 'comments#destroy'
    get     'comments/:id/edit'           => 'comments#edit',   :as => 'edit_comment'
    post    'comments/:id/screen/:screen' => 'comments#screen', :as => 'screen_comment',  :constraints => { :screen => /(0|1)/ }
  end
  
  # failthru to pages
  get '*slug' => 'page#show', :constraints => { :slug => /[a-z0-9\-_\/]+/i }, :as => '_page'
  
  # home page
  root :to => 'articles#index'
end
