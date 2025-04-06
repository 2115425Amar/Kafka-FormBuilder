# config/routes.rb
Rails.application.routes.draw do
  get  "/users/new", to: "users#new"
  post "/users",     to: "users#create"
end
