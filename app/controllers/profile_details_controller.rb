class ProfileDetailsController < ApplicationController
  # GET /profile_details
  # GET /profile_details.json
  def index
    @profile_details = ProfileDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profile_details }
    end
  end

  # GET /profile_details/1
  # GET /profile_details/1.json
  def show
    @profile_detail = ProfileDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile_detail }
    end
  end

  # GET /profile_details/new
  # GET /profile_details/new.json
  def new
    @profile_detail = ProfileDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile_detail }
    end
  end

  # GET /profile_details/1/edit
  def edit
    @profile_detail = ProfileDetail.find(params[:id])
  end

  # POST /profile_details
  # POST /profile_details.json
  def create
    @profile_detail = ProfileDetail.new(params[:profile_detail])

    respond_to do |format|
      if @profile_detail.save
        format.html { redirect_to @profile_detail, notice: 'Profile detail was successfully created.' }
        format.json { render json: @profile_detail, status: :created, location: @profile_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @profile_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profile_details/1
  # PUT /profile_details/1.json
  def update
    @profile_detail = ProfileDetail.find(params[:id])

    respond_to do |format|
      if @profile_detail.update_attributes(params[:profile_detail])
        format.html { redirect_to @profile_detail, notice: 'Profile detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_details/1
  # DELETE /profile_details/1.json
  def destroy
    @profile_detail = ProfileDetail.find(params[:id])
    @profile_detail.destroy

    respond_to do |format|
      format.html { redirect_to profile_details_url }
      format.json { head :no_content }
    end
  end

  def save_profile_details
    params[:profile].each_pair{|profile_id,value|
      profile_detail = ProfileDetail.new
      profile_detail.learner_id = params[:id]
      profile_detail.profile_id = profile_id.to_i
      profile_detail.value = value
      profile_detail.save
    }
    redirect_to("/assessments/get_structure_component/#{params[:id]}?component=#{params[:next_component]}")
  end
end
