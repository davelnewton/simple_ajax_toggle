SimpleAjaxToggle::Application.routes.draw do

  resources :articles do
    get "toggle_approve", :on => :member
  end

end
