class ProfileDropdownValuesController < ApplicationController
  # GET /profile_dropdown_values
  # GET /profile_dropdown_values.json
  def index
    @profile_dropdown_values = ProfileDropdownValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profile_dropdown_values }
    end
  end

  # GET /profile_dropdown_values/1
  # GET /profile_dropdown_values/1.json
  def show
    @profile_dropdown_value = ProfileDropdownValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile_dropdown_value }
    end
  end

  # GET /profile_dropdown_values/new
  # GET /profile_dropdown_values/new.json
  def new
    @profile_dropdown_value = ProfileDropdownValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile_dropdown_value }
    end
  end

  # GET /profile_dropdown_values/1/edit
  def edit
    @profile_dropdown_value = ProfileDropdownValue.find(params[:id])
  end

  # POST /profile_dropdown_values
  # POST /profile_dropdown_values.json
  def create
    @profile_dropdown_value = ProfileDropdownValue.new(params[:profile_dropdown_value])

    respond_to do |format|
      if @profile_dropdown_value.save
        format.html { redirect_to @profile_dropdown_value, notice: 'Profile dropdown value was successfully created.' }
        format.json { render json: @profile_dropdown_value, status: :created, location: @profile_dropdown_value }
      else
        format.html { render action: "new" }
        format.json { render json: @profile_dropdown_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profile_dropdown_values/1
  # PUT /profile_dropdown_values/1.json
  def update
    @profile_dropdown_value = ProfileDropdownValue.find(params[:id])

    respond_to do |format|
      if @profile_dropdown_value.update_attributes(params[:profile_dropdown_value])
        format.html { redirect_to @profile_dropdown_value, notice: 'Profile dropdown value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile_dropdown_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_dropdown_values/1
  # DELETE /profile_dropdown_values/1.json
  def destroy
    @profile_dropdown_value = ProfileDropdownValue.find(params[:id])
    @profile_dropdown_value.destroy

    respond_to do |format|
      format.html { redirect_to profile_dropdown_values_url }
      format.json { head :no_content }
    end
  end

  # called from profiles/create_profile view from "Add list values" href
  def add_list_values
    @existing_profile_dropdown_values = ProfileDropdownValue.find_all_by_profile_id(params[:component])
    @profile = Profile.find(params[:component])
  end

  # profile_dropdown_values/add_list_values form submite to this method when user 
  # adds a value for the profile component drop down list
  def save_dropdown_value
    dropdown_value = ProfileDropdownValue.new
    dropdown_value.value = params[:dropdown_value]
    dropdown_value.profile_id = params[:id]
    dropdown_value.save
    redirect_to("/profile_dropdown_values/add_list_values/#{dropdown_value.profile.structure_component_id}?component=#{dropdown_value.profile.id}")
  end

  # "delete" href calls this method from profile_dropdown_values/add_list_values view
  def delete_dropdown_value
    dropdown_value = ProfileDropdownValue.find(params[:id])
    structure_component_id = dropdown_value.profile.structure_component_id
    profile_id = dropdown_value.profile.id
    dropdown_value.destroy
    redirect_to("/profile_dropdown_values/add_list_values/#{structure_component_id}?component=#{profile_id}")
  end
end
