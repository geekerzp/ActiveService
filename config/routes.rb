ZhangmenrenServer::Application.routes.draw do

  get "jianghu/index"

  get "jianghu/edit"

  get "jianghu/show"

  get "goods/index"

  get "goods/new"

  get "goods/show"

  namespace :admin do
    match '/login/login' => 'login#login'
    match '/login/logout' => 'login#logout'
    match '/user/index' => 'user#index'
    match '/user/change_password' => 'user#change_password'
    match '/user/search' => 'user#search'
    match 'team/update_gongfu_equipment' => 'team#update_gongfu_equipment'
    match 'disciple/add_disciple' => 'disciple#add_disciple'
    match 'equipment/add_equipment' => 'equipment#add_equipment'
    match 'gongfu/add_gongfu' => 'gongfu#add_gongfu'
    match 'jianghu/scene_names' => 'jianghu#scene_names'
    match 'jianghu/item_names' => 'jianghu#item_names'
    match 'jianghu/scene_item_names' => 'jianghu#scene_item_names'
    match 'canzhang/gongfu_names' => 'canzhang#gongfu_names'
    match 'canzhang/canzhang_types' => 'canzhang#canzhang_types'
    match 'team/change_equipment' => 'team#change_equipment'
    match 'team/change_gongfu' => 'team#change_gongfu'
    match 'equipment/get_equipment_type_name' => 'equipment#get_equipment_type_name'
    match 'recharge/get_order_number' => 'recharge#get_order_number'
    match 'recharge/get_recharge_status' => 'recharge#get_recharge_status'
    resources :user
    resources :team
    resources :disciple
    resources :gongfu
    resources :soul
    resources :equipment
    resources :zhangmenjue
    resources :canzhang
    resources :goods
    resources :jianghu
  end
  root :to => 'admin/login#login'
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # root :to => 'welcome#index'

  match ':controller(/:action(/:id))(.:format)'
end
