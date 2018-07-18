class HomeController < ApplicationController
  def index

  end

  def lionsher_homepage2

  end

  def lionsher_homepage3

  end

  def lionsher_homepage4

  end

  def features

  end

  def tests

  end

  def easy_to_use

  end

  def cost_effective

  end

  def highly_secure

  end

  def customizable

  end

  def scalable

  end

  def anywhere_access

  end

  def pricing

  end

  def pricing_in_dollars

  end

  def case_studies1

  end

  def case_studies2

  end

  def case_studies3

  end

  def case_studies4

  end

  def about_us

  end

  def contact_us

  end

  def save_contact_details
    @home = SaveContactDetails.new(params[:home])
    if @home.save
      flash[:notice] = "Data saved Successfully."
      redirect_to('/contact_us_url')
    end
  end

  def sign_in

  end

  def forgot_password

  end

  def terms_and_conditions

  end

  def privacy_policy

  end
end
#class HomeController < ApplicationController
# require 'yaml'
#
#  def index
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher Home: Easy to use LMS"
#  end
#
#  def features_cost_effective
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features - Cost-effective"
#  end
#
#  def features_easy_to_use
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features- Easy to use"
#  end
#
#  def features_highly_secure
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features - Highly secure"
#  end
#
#  def features_customizable
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features - Customizable"
#  end
#
#  def features_scalable
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features - Scalable"
#  end
#
#  def features_any_where_access
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Features - Any Where Access"
#  end
#
#  def benefits_small_business
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Benefits - Small Business"
#  end
#
#  def benefits_mid_sized_corporate
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Benefits - Mid-Sized Corporate"
#  end
#
#  def benefits_educational_institution
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Benefits - Educational Institution"
#  end
#
#  def benefits_individual_trainer
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title= "LionSher: Benefits - Individual Trainer"
#  end
#
#  def pricing_rupees
#   @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Pricing - Rupees"
#  end
#
#  def contact_us
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Contact us"
#  end
#
#  def about_us
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: About us"
#  end
#
#  def terms
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Terms and Conditions"
#  end
#
#  def privacy_policy
#    @rules = YAML::load(File.open("#{Rails.root}/config/website_content.yml"))
#    @page_title="LionSher: Privacy Policy"
#  end
#
#  def tests
#    @page_title="LionSher: Tests"
#  end
#
#  def tests_contact_us
#    @page_title="LionSher: Tests Contact Us"
#  end
#
#  def save_test_contact_us_details
##     UserMailer.test_contact_us_details(subscribe,params[:number_of_users],params[:frequency_of_tests]).deliver
#    subscribe = Subscribe.new(params[:subscribe])
#    subscribe.save
#    admin = subscribe
#
#    from_replacements = Hash["[sender_name]" => admin.name,
#                         "[sender_email]" => admin.email
#                          ]
#
#    subject_replacements = Hash["[sender_name]" => admin.login,
#                         "[sender_email]" => admin.email
#                        ]
#
#    body_replacements =  Hash["[sender_name]" => admin.login,
#                         "[sender_email]" => admin.email
#                        ]
#
#    UserMailer.send_mail(subscribe,'test_contact_us_details',0,from_replacements,subject_replacements,body_replacements).deliver
##    UserMailer.deliver_test_contact_us_details(subscribe,params[:number_of_users],params[:frequency_of_tests])
#    flash[:test_buy_mail_sent] = "Email has been sent. We will contact you as soon as possible."
#    redirect_to("/tests")
#  end
#
#  def tests_pricing
#
#  end
#end
