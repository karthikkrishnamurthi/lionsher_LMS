class EmailsController < ApplicationController
  before_filter :login_required


  def example
    
  end
  
  # GET /emails
  # GET /emails.xml
  def index
    @emails = Email.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emails }
    end
  end

  # GET /emails/1
  # GET /emails/1.xml
  def show
    @email = Email.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email }
    end
  end

  #control comes here when ajax call is made from emails/new page whenever user select different mail type in dropdownlist
  # finds the email from Emails table and redirects to /emails/get_email_content_for_email_type.rjs
  def get_email_content_for_email_type
    @all_emails = current_user.emails.find_by_email_type(params[:id])
    if @all_emails.nil? then
      @all_emails = Email.find_by_email_type_and_user_id(params[:id],nil)
      respond_to do |format|
        format.html {redirect_to("/emails/new/1")}
        format.js
      end
    end
  end

  # GET /emails/new
  # GET /emails/new.xml
  def new
    @all_emails = current_user.emails.find_by_email_type('signup_assessment_learner_notification')
    if @all_emails.nil? then
      @all_emails = Email.find_by_email_type_and_user_id('signup_assessment_learner_notification',nil)
    end
  end

  # GET /emails/1/edit
  def edit
    @email = Email.find(params[:id])
  end

  #creates new email for the tenant(if not present till now) when he make any editions and clicks save, else if already has custom email then just update
  def create
    email_for_tenant = current_user.emails.find_by_email_type(params[:email][:email_type])
    if email_for_tenant.nil?
      @email = Email.new(params[:email])
      @email.save
    else
      email_for_tenant.update_attributes(params[:email])
    end
    flash[:notice] = "Changes have been saved"
    redirect_to("/emails/new")
  end

  # PUT /emails/1
  # PUT /emails/1.xml
  def update
    @email = Email.find(params[:id])
    flash[:notice] = "Changes have been saved"
    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = 'Email was successfully updated.'
        format.html { redirect_to(@email) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.xml
  def destroy
    @email = Email.find(params[:id])
    @email.destroy

    respond_to do |format|
      format.html { redirect_to(emails_url) }
      format.xml  { head :ok }
    end
  end
end
