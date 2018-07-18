class PricingPlansController < ApplicationController

  before_filter :login_required
  # before_filter :is_superuser?, :except => [:plan_selected,:all_plans]

  # GET /pricing_plans
  # GET /pricing_plans.xml
  def index
    @pricing_plans = PricingPlan.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pricing_plans }
    end
  end

  # GET /pricing_plans/1
  # GET /pricing_plans/1.xml
  def show
    @pricing_plan = PricingPlan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pricing_plan }
    end
  end

  # GET /pricing_plans/new
  # GET /pricing_plans/new.xml
  def new
    @pricing_plan = PricingPlan.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pricing_plan }
    end
  end

  # GET /pricing_plans/1/edit
  def edit
    @pricing_plan = PricingPlan.find(params[:id])
  end

  # POST /pricing_plans
  # POST /pricing_plans.xml
  def create
    @pricing_plan = PricingPlan.new(params[:pricing_plan])

    respond_to do |format|
      if @pricing_plan.save
        flash[:notice] = 'PricingPlan was successfully created.'
        format.html { redirect_to(@pricing_plan) }
        format.xml  { render :xml => @pricing_plan, :status => :created, :location => @pricing_plan }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pricing_plan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pricing_plans/1
  # PUT /pricing_plans/1.xml
  def update
    @pricing_plan = PricingPlan.find(params[:id])

    respond_to do |format|
      if @pricing_plan.update_attributes(params[:pricing_plan])
        flash[:notice] = 'PricingPlan was successfully updated.'
        format.html { redirect_to(@pricing_plan) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pricing_plan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pricing_plans/1
  # DELETE /pricing_plans/1.xml
  def destroy
    @pricing_plan = PricingPlan.find(params[:id])
    @pricing_plan.destroy

    respond_to do |format|
      format.html { redirect_to(pricing_plans_url) }
      format.xml  { head :ok }
    end
  end

  def plan_selected
    
    # redirect_to('/transactions/confirm_payment/'+params[:plan_selected])
  end

  #this method is used to display the current plan which the tenant is using now and what plan he has selected and what are the available public plans if he wants to upgrade
  def all_plans
    if current_user.typeofuser == "admin" then
      @tenant = current_user.tenant
      @current_plan = @tenant.pricing_plan
      @selected_plan = PricingPlan.find(@tenant.selected_plan_id)
      @pricing_plans = PricingPlan.where(:plan_type => 'public')
    end
  end
  
end
