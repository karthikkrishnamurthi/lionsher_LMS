class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end

  # when user clicks on "profile" href in structure_components/create_structure view,
  # then this method is called from structure_components/component_details method using this line:
  # redirect_to("/#{component_name}s/create_#{component_name}/#{@structure_component.id}")
  def create_profile
    @structure_component = StructureComponent.find(params[:id])
    @existing_profile_components = Profile.find_all_by_structure_component_id(@structure_component.id)
  end

  # when user clicks on "profile field_name" href in profile/create_profile view,
  # then this method is called
  def edit_profile
    @profile = Profile.find(params[:id])
    @structure_component = StructureComponent.find(@profile.structure_component_id)
  end

  # profiles/create_profile form submits to this method to save profile
  def save_profile
    @structure_component = StructureComponent.find(params[:id])
    @profile = Profile.new
    @profile.field_name = params[:field_name]
    @profile.field_type = params[:field_type]
    @profile.structure_component_id = @structure_component.id
    @profile.tenant_id = @structure_component.tenant_id
    @profile.save
    @structure_component.update_attribute(:is_saved, "true")
    redirect_to("/profiles/create_profile/#{@structure_component.id}")
  end

  # called from "delete" href in profiles/edit_profile view
  def delete_profile_component
    @profile = Profile.find(params[:id])
    @structure_component = StructureComponent.find(@profile.structure_component_id)
    @profile.destroy
    redirect_to("/profiles/create_profile/#{@structure_component.id}")
  end

  # called from profiles/create_profile when user clicks on a profile component
  def edit_profile_component
    @structure_component = StructureComponent.find(params[:id])
    @profile = Profile.find(params[:component])
    redirect_to("/profiles/edit_profile/#{@profile.id}")
  end

  # profiles/edit_profile form submits to this method
  def update_profile
    @profile = Profile.find(params[:id])
    @profile.update_attribute(:field_name,params[:field_name])
    @profile.update_attribute(:field_type,params[:field_type])
    redirect_to("/profiles/create_profile/#{@profile.structure_component_id}")
  end
  
end
