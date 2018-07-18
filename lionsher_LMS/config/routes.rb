Lionsher::Application.routes.draw do

  resources :component_widget_variables

  resources :widget_variables

  resources :report_variables

  resources :component_widgets

  resources :widgets

  resources :report_components

  resources :report_templates

  resources :profile_details

  resources :profile_dropdown_values

  resources :instructions

  resources :profiles

  resources :sections

  resources :structure_components

  resources :assessment_components

  resources :calculated_data_learner_assessments

  resources :calculated_data_assessments

  resources :assessment_rules

  resources :rules
  resources :tags
  resources :tagvalues
  resources :question_tags
  resources :apis
  resources :packages

  resources :assessment_courses

  resources :test_details

  resources :posts
  resources :bugz_profiles
  resources :issues
  
  resources :emails
  resources :pulse_surveys
  resources :test_patterns
  resources :pricing_plans
  resources :sellers
  resources :buyers
  resources :transactions
  resources :question_banks
  resources :home
  resources :learners
  resources :users
  resources :sessions
  resources :admin

  resources :subscribes
  resources :courses
  resources :blogs
  resources :tenants
  resources :assessment_questions
  resources :assessments
  resources :imports
  resources :answers
  resources :questions
  match '/pswrd_reset/:reset_code' => 'users#pswrd_reset'
  #check lib/subdomain.rb. If request match www then redirect to root i.e home#index else if subdomain is present then redirect to sessions/login
  constraints(Subdomain) do
      match '/' => 'sessions#login'
    end
  root :to => 'home#index'
  match '/coupon/validate' => 'coupons#validate'
  match '/coupon' => 'coupons#coupon'
  match '/transactions/export_pdf/:id' => 'transactions#export_pdf', :format => 'pdf'
  match '/document_viewer/:id' => 'document_viewer#index'
  match '/home/index'=> 'home#index'
  match '/lionsher_homepage2' => 'home#lionsher_homepage2'
  match '/lionsher_homepage3' => 'home#lionsher_homepage3'
  match '/lionsher_homepage4', :controller => "home", :action => "lionsher_homepage4"
  match '/features', :controller => "home", :action => "features"
  match '/tests', :controller => "home", :action => "tests"
  match '/easy_to_use', :controller => "home", :action => "easy_to_use"
  match '/cost_effective', :controller => "home", :action => "cost_effective"
  match '/highly_secure', :controller => "home", :action => "highly_secure"
  match '/customizable', :controller => "home", :action => "customizable"
  match '/scalable', :controller => "home", :action => "scalable"
  match '/anywhere_access', :controller => "home", :action => "anywhere_access"
  match '/pricing', :controller => "home", :action => "pricing"
  match '/pricing_in_dollars', :controller => "home", :action => "pricing_in_dollars"
  match '/case_studies1', :controller => "home", :action => "case_studies1"
  match '/case_studies2', :controller => "home", :action => "case_studies2"
  match '/case_studies3', :controller => "home", :action => "case_studies3"
  match '/case_studies4', :controller => "home", :action => "case_studies4"
  match '/about_us', :controller => "home", :action => "about_us"
  match '/contact_us', :controller => "home", :action => "contact_us"
  match '/sign_in', :controller => "home", :action => "sign_in"
  match '/forgot_password', :controller => "home", :action => "forgot_password"
  match '/terms_and_conditions', :controller => "home", :action => "terms_and_conditions"
  match '/privacy_policy', :controller => "home", :action => "privacy_policy"

#  match '/features_cost_effective' => 'home#features_cost_effective'
#  match '/features_easy_to_use' => 'home#features_easy_to_use'
#  match '/features_highly_secure' => 'home#features_highly_secure'
#  match '/features_customizable' => 'home#features_customizable'
#  match '/features_scalable' => 'home#features_scalable'
#  match '/features_any_where_access' => 'home#features_any_where_access'
#  match '/benefits_small_business' => 'home#benefits_small_business'
#  match '/benefits_mid_sized_corporate' => 'home#benefits_mid_sized_corporate'
#  match '/benefits_educational_institution' => 'home#benefits_educational_institution'
#  match '/benefits_individual_trainer' => 'home#benefits_individual_trainer'
#  match '/pricing_dollar' => 'home#pricing_dollar'
#  match '/pricing_rupees' => 'home#pricing_rupees'
#  match '/contact_us' => 'home#contact_us'
#  match '/about_us' => 'home#about_us'
#  match '/terms' => 'home#terms'
#  match '/privacy_policy' => 'home#privacy_policy'
#  match '/tests' => 'home#tests'
#  match '/tests_contact_us' => 'home#tests_contact_us'
#  match '/tests_pricing' => 'home#tests_pricing'
  match '/my_account' => 'users#my_account'

  match '/learningden' => 'blogs#learningden'
  match '/learningden/mathew_kuruvilla' => 'blogs#show', :id => 1
  match '/learningden/tricia_morente' => 'blogs#show', :id => 2
  match '/learningden/sheila_jagannathan' => 'blogs#show', :id => 3
  match '/learningden/dilip_mohapatra' => 'blogs#show', :id => 4
  match '/learningden/gautam_ghosh' => 'blogs#show', :id => 5
  match '/learningden/alok_asthana' => 'blogs#show', :id => 6
  match '/learningden/archana_tyagi' => 'blogs#show', :id => 7
  match '/learningden/lionsher_vs_moodle' => 'blogs#show', :id => 8
  match '/learningden/creative_ways' => 'blogs#show', :id => 9
  match '/learningden/easy_recruitment' => 'blogs#show', :id => 10
  match '/learningden/myths_and_realities' => 'blogs#show', :id => 11
  match '/learningden/ripul_kumar' => 'blogs#show', :id => 12
  match '/learningden/karthik_krishnamurthi' => 'blogs#show', :id => 13
  match '/about' => 'blogs#about'
  match '/contact' => 'blogs#contact'
  match '/learningden/rss' => 'blogs#index', :format => 'rss'
  match '/:controller/:action/:id' => '#index'
  match '/:controller/:action' => '#index'
  match '/activate/:activation_code' => 'users#activate'
  match '/mycourses' => 'courses#mycourses'
  match '/mypapers' => 'courses#mypapers'
  match '/logout' => 'sessions#logout'
  match '/forgot' => 'users#forgot'
  match '/coursestore/:custom_url' => 'course_store#courses_for_vendor'
  match '/flash/upload' => 'uploads#index'
  resources :coupons
  resources :assessment_packages
end
