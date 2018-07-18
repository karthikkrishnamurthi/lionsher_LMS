# Subscription
# Author : Karthik
class SubscribesController < ApplicationController
  
  def index
    @subscribes = Subscribe.find(:all)
  end

 
  def show
    @subscribe = Subscribe.find(params[:id])
  end

 
  def new
    @subscribe = Subscribe.new
  end

  
  def edit
    @subscribe = Subscribe.find(params[:id])
  end

 
  def create
    @subscribe = Subscribe.new(params[:subscribe])
    @subscribe.save
    redirect_to("/")
  end

  
  def update
    @subscribe = Subscribe.find(params[:id])
    @subscribe.update_attributes(params[:subscribe])
    redirect_to(@subscribe)
  end


  def destroy
    @subscribe = Subscribe.find(params[:id])
    @subscribe.destroy
    redirect_to(subscribes_url)
  end

  def dummy_save_buyer_seller_details
    if params.include? "seller" then
      subscribe = Subscribe.new(params[:seller])
      subscribe.save
    else
      subscribe = Subscribe.new(params[:buyer])
      subscribe.save
      subscribe.update_attribute(:course_id, params[:id])
    end
    redirect_to('/course_store')
  end

end
