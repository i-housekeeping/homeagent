ActionController::Routing::Routes.draw do |map|
  map.resources :collaborates, :collection => { :index_remote=>:get,
                                                :update_remote=>:get,
                                                :destroy_remote=>:get,
                                                :create_remote=>:get, 
                                                :postdirectory=>:get, 
                                                :adoptdirectory=>:get,
                                                :collaborates_sharelist => :get,
                                                :cleandirectory => :get}

  map.resources :notes, :collection => {    :index_remote=>:get,
                                            :update_remote=>:get,
                                            :destroy_remote=>:get,
                                            :create_remote=>:get, 
                                            :postdirectory=>:get, 
                                            :adoptdirectory=>:get,
                                            :notes_sharelist => :get,
                                            :cleandirectory => :get}

  map.resources :tasklists, :collection => {:index_remote=>:get,
                                            :update_remote=>:get,
                                            :destroy_remote=>:get,
                                            :create_remote=>:get, 
                                            :postdirectory=>:get, 
                                            :adoptdirectory=>:get,
                                            :tasklists_sharelist => :get,
                                            :cleandirectory => :get}

  map.resources :tasks, :collection => {:index_remote=>:get,
                                        :update_remote=>:get,
                                        :destroy_remote=>:get,
                                        :create_remote=>:get, 
                                        :postdirectory=>:get, 
                                        :adoptdirectory=>:get,
                                        :tasks_sharelist => :get,
                                        :cleandirectory => :get}

  map.resources :cashrecords, :collection => {:wizard=>:get,
                                              :grid_data=>:get, 
                                              :list=>:get, 
                                              :user_histories=>:get, 
                                              :history=> :get,
                                              :upload=>:post,
                                              :progress=>:post,
                                              :index_remote=>:get,
                                              :update_remote=>:get,
                                              :destroy_remote=>:get,
                                              :create_remote=>:get, 
                                              :postdirectory=>:get, 
                                              :adoptdirectory=>:get,
                                              :cashrecords_sharelist => :get,
                                              :cleandirectory => :get}

  map.resources :contacts, :has_many => [:accounts, :cashrecords], 
                                        :collection => {:loadtable=>:get, 
                                                        :sendmail=>:get, 
                                                        :comapanies_list=>:get, 
                                                        :index_remote=>:get,
                                                        :update_remote=>:get,
                                                        :destroy_remote=>:get,
                                                        :create_remote=>:get, 
                                                        :postdirectory=>:get, 
                                                        :adoptdirectory=>:get,
                                                        :contacts_sharelist => :get,
                                                        :cleandirectory => :get}

  map.resources :accounts, :has_many => :cashrecords,  
                                    :collection => {    :index_remote=>:get,
                                                        :update_remote=>:get,
                                                        :destroy_remote=>:get,
                                                        :create_remote=>:get, 
                                                        :postdirectory=>:get, 
                                                        :adoptdirectory=>:get,
                                                        :accounts_sharelist => :get,
                                                        :cleandirectory => :get}

  map.resources :banks, :has_many => :accounts,
                                    :collection => {    :index_remote=>:get,
                                                        :update_remote=>:get,
                                                        :destroy_remote=>:get,
                                                        :create_remote=>:get, 
                                                        :postdirectory=>:get, 
                                                        :adoptdirectory=>:get,
                                                        :banks_sharelist => :get,
                                                        :cleandirectory => :get}
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "homeagent"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
