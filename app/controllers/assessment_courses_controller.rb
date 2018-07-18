class AssessmentCoursesController < ApplicationController
  before_filter :login_required
  
  # GET /assessment_courses
  # GET /assessment_courses.json
  def index
    @assessment_courses = AssessmentCourse.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessment_courses }
    end
  end

  # GET /assessment_courses/1
  # GET /assessment_courses/1.json
  def show
    @assessment_course = AssessmentCourse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessment_course }
    end
  end

  # GET /assessment_courses/new
  # GET /assessment_courses/new.json
  def new
    @assessment_course = AssessmentCourse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment_course }
    end
  end

  # GET /assessment_courses/1/edit
  def edit
    @assessment_course = AssessmentCourse.find(params[:id])
  end

  #called from form submit in new_assessment_course.html. creates a record in AssessmentCourses table.
  def create
    if params[:assessment_course_id].include? 'course'
      params[:assessment_course][:course_id] = params[:assessment_course_id].split(':')[1].to_i
    elsif params[:assessment_course_id].include? 'assessment'
      params[:assessment_course][:assessment_id] = params[:assessment_course_id].split(':')[1].to_i
    end

    @assessment_course = AssessmentCourse.new(params[:assessment_course])
    @assessment_course.save
    redirect_to "/assessment_courses/new_assessment_course/#{params[:assessment_course][:package_id]}"
  end

  # PUT /assessment_courses/1
  # PUT /assessment_courses/1.json
  def update
    @assessment_course = AssessmentCourse.find(params[:id])

    respond_to do |format|
      if @assessment_course.update_attributes(params[:assessment_course])
        format.html { redirect_to @assessment_course, notice: 'Assessment course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment_course.errors, status: :unprocessable_entity }
      end
    end
  end

  #called from link 'remove' from the partial "/assessment_courses/packaged_assessment_courses"
  def destroy
    @assessment_course = AssessmentCourse.find_by_id(params[:id])
    unless @assessment_course.nil?
      @assessment_course.destroy
    end
    redirect_to "/assessment_courses/new_assessment_course/#{@assessment_course.package_id}"
  end

  #After creating package(check packages/create method), it redirects to this method
  # calculates the total number of valid assessments and valid courses for that tenant for displaying in the dropdownlist
  def new_assessment_course
    @assessments = current_user.assessments.where("no_of_questions > 0")
    @courses = current_user.courses.where("size > 0")
    @current_package = current_user.packages.where("id = #{params[:id]}")[0]
  end

  #called from link 'remove' from the partial "/assessment_courses/packaged_assessment_courses" but from edit_package page
  def destroy_from_edit
    @assessment_course = AssessmentCourse.find_by_id(params[:id])
    unless @assessment_course.nil?
      @assessment_course.destroy
    end
    redirect_to "/packages/edit_package/#{@assessment_course.package_id}"
  end

  #called from form submit in /packages/edit_package.html. creates a record in AssessmentCourses table.
  def add_more_from_edit
    if params[:assessment_course_id].include? 'course'
      params[:assessment_course][:course_id] = params[:assessment_course_id].split(':')[1].to_i
    elsif params[:assessment_course_id].include? 'assessment'
      params[:assessment_course][:assessment_id] = params[:assessment_course_id].split(':')[1].to_i
    end

    @assessment_course = AssessmentCourse.new(params[:assessment_course])
    @assessment_course.save
    redirect_to "/packages/edit_package/#{params[:assessment_course][:package_id]}"
  end
end
