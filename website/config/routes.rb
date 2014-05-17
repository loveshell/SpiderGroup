Website::Application.routes.draw do
  get "submit/edit"
  get "submit/index"
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'content#index'
  get 'check' => 'content#check'
  get 'all' => 'content#all'
  get 'bigbrother' => 'content#bigbrother'
  get 'newbie' => 'content#newbie'
  get 'people' => 'content#people'
  get 'security' => 'content#security'
  get 'code' => 'content#code'
  get 'cool' => 'content#cool'
  get 'webmaster' => 'content#webmaster'

  get 'Freebuf' => 'content#Freebuf'
  get 'iheima' => 'content#iheima'
  get 'huxiu' => 'content#huxiu'
  get 'vaikan' => 'content#vaikan'
  get 'lusongsong' => 'content#lusongsong'
  get 'kr36' => 'content#kr36'
  get '36kr' => 'content#kr36'
  get 'fastcompany' => 'content#fastcompany'
  

  get 'vote' => 'content#vote'
  get 'word' => 'content#word'

  post 'publish' => 'content#publish'
  post 'favorite' => 'content#favorite'
  get 'myfavorite' => 'content#myfavorite'
  post 'like' => 'content#like'
  get 'favoritelogin/:id' => 'content#favoritelogin'
  get 'likelogin/:id' => 'content#likelogin'
  get 'submit' => 'content#new'
  post 'submit' => 'content#create'

  resources :content
  resources :comments

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
