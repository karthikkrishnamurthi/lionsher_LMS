class PulseSurveysController < ApplicationController
  # GET /pulse_surveys
  # GET /pulse_surveys.xml
  def index
    @pulse_surveys = PulseSurvey.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pulse_surveys }
    end
  end

  # GET /pulse_surveys/1
  # GET /pulse_surveys/1.xml
  def show
    @pulse_survey = PulseSurvey.find(params[:id])
    render :layout => false
  end

  # GET /pulse_surveys/new
  # GET /pulse_surveys/new.xml
  def new
    @pulse_survey = PulseSurvey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pulse_survey }
    end
  end

  # GET /pulse_surveys/1/edit
  def edit
    @pulse_survey = PulseSurvey.find(params[:id])
  end

  # POST /pulse_surveys
  # POST /pulse_surveys.xml
  def create
    params[:pulse_survey][:coupon_code] = ActiveSupport::SecureRandom.hex(6)
    @pulse_survey = PulseSurvey.new(params[:pulse_survey])

    respond_to do |format|
      if @pulse_survey.save
        flash[:notice] = 'PulseSurvey was successfully created.'
        format.html { redirect_to(@pulse_survey) }
        format.xml  { render :xml => @pulse_survey, :status => :created, :location => @pulse_survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pulse_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pulse_surveys/1
  # PUT /pulse_surveys/1.xml
  def update
    @pulse_survey = PulseSurvey.find(params[:id])

    respond_to do |format|
      if @pulse_survey.update_attributes(params[:pulse_survey])
        flash[:notice] = 'PulseSurvey was successfully updated.'
        format.html { redirect_to(@pulse_survey) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pulse_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pulse_surveys/1
  # DELETE /pulse_surveys/1.xml
  def destroy
    @pulse_survey = PulseSurvey.find(params[:id])
    @pulse_survey.destroy

    respond_to do |format|
      format.html { redirect_to(pulse_surveys_url) }
      format.xml  { head :ok }
    end
  end

  def validate
    @pulse_survey = PulseSurvey.find_by_coupon_code(params[:id])
    unless @pulse_survey.nil? or @pulse_survey.blank? then
      redirect_to "/pulse_surveys/show/#{@pulse_survey.id}"
    else
    end
  end

  def send_survey_mails
    @pulse_survey = PulseSurvey.find(:all, :conditions => "id > 2530")
    @pulse_survey.each { |rec|
      url="https://www.lionsher.com/pulse_surveys/validate/#{rec.coupon_code}"
#      UserMailer.send_survey_mails(rec,url).deliver
    }

  end
end
