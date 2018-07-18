class AssessmentPackagesController < ApplicationController
before_filter :login_required

  def move_data
    p = PackagesController.new
    p.delay.moving_data(params[:id])
  end

  # GET /assessment_packages
  # GET /assessment_packages.xml
  def index
    @assessment_packages = AssessmentPackage.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assessment_packages }
    end
  end

  # GET /assessment_packages/1
  # GET /assessment_packages/1.xml
  def show
    @assessment_package = AssessmentPackage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assessment_package }
    end
  end

  # GET /assessment_packages/new
  # GET /assessment_packages/new.xml
  def new
    @assessment_package = AssessmentPackage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assessment_package }
    end
  end

  # GET /assessment_packages/1/edit
  def edit
    @assessment_package = AssessmentPackage.find(params[:id])
  end

  # POST /assessment_packages
  # POST /assessment_packages.xml
  def create
    @assessment_package = AssessmentPackage.new(params[:assessment_package])

    respond_to do |format|
      if @assessment_package.save
        flash[:notice] = 'AssessmentPackage was successfully created.'
        format.html { redirect_to(@assessment_package) }
        format.xml  { render :xml => @assessment_package, :status => :created, :location => @assessment_package }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assessment_package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assessment_packages/1
  # PUT /assessment_packages/1.xml
  def update
    @assessment_package = AssessmentPackage.find(params[:id])

    respond_to do |format|
      if @assessment_package.update_attributes(params[:assessment_package])
        flash[:notice] = 'AssessmentPackage was successfully updated.'
        format.html { redirect_to(@assessment_package) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assessment_package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assessment_packages/1
  # DELETE /assessment_packages/1.xml
  def destroy
    @assessment_package = AssessmentPackage.find(params[:id])
    @assessment_package.destroy

    respond_to do |format|
      format.html { redirect_to(assessment_packages_url) }
      format.xml  { head :ok }
    end
  end

  def save_package
    if AssessmentPackage.find_by_id(params[:assessment_package][:id]).nil?
      @assessment_package = AssessmentPackage.new
      @assessment_package.id = params[:assessment_package][:id]
      @assessment_package.name = params[:assessment_package][:name]
      @assessment_package.tenant_id = current_user.tenant_id
      @assessment_package.user_id = current_user.id
      @assessment_package.save
      redirect_to ("/coupons/generate_codes/#{@assessment_package.id}?for_course_assessment_package=assessment_package")
    else
      flash[:notice] = "Package ID already exists."
      redirect_to("/assessment_packages/create_package/1")
    end
  end

  def assessments_with_package_id
    @assessments= current_user.assessments
  end

  def update_assessments_with_package_id
#    assessment_list = params[:assessments].split(",")
    params[:assessments].keys.each { |assmt|
      assessment = Assessment.find(assmt)
      assessment.update_attribute(:assessment_package_id, params[:assessment_package][:id])
    }
    assmt_package = AssessmentPackage.find(params[:assessment_package][:id])
    assmt_package.update_attribute(:assessment_order,params[:assessments_order])
    redirect_to "/courses"
  end
end
