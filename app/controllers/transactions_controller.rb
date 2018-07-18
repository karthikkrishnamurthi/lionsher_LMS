class TransactionsController < ApplicationController

  before_filter :login_required
  before_filter :is_superuser?, :except => [:confirm_payment, :payment_done, :show,:export_pdf,:course_payment_done]

  def index
    @transactions = Transaction.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transactions }
    end
  end

  def new
    
  end

  #control comes here from /pricing_plans/all_plans.html when the user select a particular plan to upgrade.
  #saves a transaction log with incomplete status(just for our reference) and store in transaction_logs table and redirect to confirm_payment.html
  def confirm_payment
    session[:plan_selected] = params[:id]
    @tenant = current_user.tenant
    @reference_no = params[:transaction_log][:reference_no]
    # @tenant = Tenant.find_by_user_id(current_user.id)
    @pricing_plan = PricingPlan.find(params[:id])
    transaction_log = TransactionLog.new(params[:transaction_log])
    transaction_log.save
    @transaction = Transaction.find_all_by_tenant_id(@tenant.id).last
  end

  #This method is for downloading Invoice of a resepective transaction. Needed prawn and gem version >1.3.6
  def export_pdf
    @transaction = Transaction.find_by_id(params[:id])
    @tenant = current_user.tenant

    @pricing_plan = @transaction.pricing_plan
    @pricing_plan.amount

    respond_to do |format|
      format.html # show.html.erb
      format.pdf { render :layout => false }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        flash[:notice] = 'Transaction was successfully created.'
        format.html { redirect_to(@transaction) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(@transaction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Control comes here from transactions/show method (check transactions/show method). Since the payment is out of application operation, make a check if the session 'current_user' exists if it doesnt redirect to '/' .
  #If the session is still persisting, check if the transaction with so and so tenant_id and params[:id](viz transaction_id) already exists or not.
  #Perform the inner operations only if the calculated transation obj is not nil and payment_done is nil because the same transaction cant be made again and again.
  def payment_done
    unless current_user.nil? then
      tenant = Tenant.find_by_user_id(current_user.id)
      transaction = Transaction.find_by_tenant_id_and_id(tenant.id,params[:id])
      unless transaction.nil?
        if transaction.payment_done.nil?
          transaction.update_attribute(:payment_done, 1)
          unless session[:plan_slected].nil? then
            pricing_plan = PricingPlan.find(session[:plan_selected])
          else
            transaction_log = TransactionLog.find_by_reference_no_and_user_id(transaction.merchant_refno,current_user.id)
            unless transaction_log.nil?
              pricing_plan = PricingPlan.find(transaction_log.pricing_plan_id)
            end
          end
          if transaction.response_code == 0 then
            if Time.now.utc >= tenant.expiry_date then   # SCENARIO: If the tenant account expired 2 days back and upgrades plan today then count the expiry_date from today.. dont consider the previous 2 days.
              tenant_new_expiry_date = Time.now.utc + pricing_plan.plan_expiry*(365*24*60*60)
              tenant.update_attribute(:expiry_date, tenant_new_expiry_date)
            else                                         #SECNARIO: If the tenant upgrades the plan today but his actual expiry date is 2 days later then add the 2 days to the upgraded expiry.
              tenant_new_expiry_date = tenant.expiry_date + pricing_plan.plan_expiry*(365*24*60*60)
              tenant.update_attribute(:expiry_date, tenant_new_expiry_date)
            end
            unless session[:plan_slected].nil? then
              transaction.update_attribute(:pricing_plan_id,session[:plan_selected])
              tenant.update_attribute(:pricing_plan_id, session[:plan_selected])
              tenant.update_attribute(:is_expired, "false")
            else
              transaction_log = TransactionLog.find_by_reference_no_and_user_id(transaction.merchant_refno,current_user.id)
              unless transaction_log.nil?
                transaction_log.update_attributes(:transaction_status => "complete",:transaction_id => transaction.id)
                transaction.update_attribute(:pricing_plan_id,transaction_log.pricing_plan_id)
                tenant.update_attribute(:pricing_plan_id,transaction_log.pricing_plan_id)
                tenant.update_attribute(:is_expired, "false")
              end
            end
          else
            transaction_log = TransactionLog.find_by_reference_no_and_user_id(transaction.merchant_refno,current_user.id)
            unless transaction_log.nil?
              transaction_log.update_attributes(:transaction_status => "error",:transaction_id => transaction.id)
            end
          end
          redirect_to("/my_account/?transaction_id="+transaction.id.to_s)
        else
          redirect_to("/my_account")
        end
      else
        redirect_to("/my_account")
      end
    else
      redirect_to("/")
    end
  end


  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end

  #this is method to which EBS redirects after makins its functionality. Here we save all the details it sends in transaction table
  def show
    #the below files are useful to decrypt the params which EBS has sent
    require 'RubyRc4.rb'
    require 'base64'
    @key = EBS_KEY
    @DR = params[:DR]
    @DR.gsub!(/ /,'+')

    @encrypted_data = Base64.decode64(@DR)

    @decryptor = RubyRc4.new(@key)

    @plain_text = @decryptor.encrypt(@encrypted_data)

    puts "HTTP/1.0 200 OK"
    puts "Content-type: text/html\n\n"
    transaction = Hash.new
    tenant = Tenant.find_by_user_id(current_user.id)
    @plain_text.split(/&/).each_with_index do |item, i|
      key, val = item.split(=)
      if key == 'PaymentID' then
        transaction['payment_id'] = val
      end
      if key == 'MerchantRefNo' then
        transaction['merchant_refno'] = val
      end
      if key == 'Amount' then
        transaction['amount'] = val
      end
      if key == 'Mode' then
        transaction['mode'] = val
      end
      if key == 'Description' then
        transaction['description'] = val
      end
      if key == 'DateCreated' then
        transaction['date_created'] = val
      end
      if key == 'IsFlagged' then
        transaction['is_flagged'] = val
      end
      if key == 'TransactionID' then
        transaction['transaction_id'] = val
      end
      if key == 'ResponseMessage' then
        transaction['response_message'] = val
      end
      if key == 'ResponseCode' then
        transaction['response_code'] = val
      end

      if key == 'BillingAddress' then
        transaction['billing_address'] = val
      end
      if key == 'BillingCity' then
        transaction['billing_city'] = val
      end
      if key == 'BillingState' then
        transaction['billing_state'] = val
      end
      if key == 'BillingPostalCode' then
        transaction['billing_postal_code'] = val
      end
      if key == 'BillingCountry' then
        transaction['billing_country'] = val
      end
      if key == 'BillingPhone' then
        transaction['billing_phone'] = val
      end

      if key == 'DeliveryAddress' then
        transaction['delivery_address'] = val
      end
      if key == 'DeliveryCity' then
        transaction['delivery_city'] = val
      end
      if key == 'DeliveryState' then
        transaction['delivery_state'] = val
      end
      if key == 'DeliveryPostalCode' then
        transaction['delivery_postal_code'] = val
      end
      if key == 'DeliveryCountry' then
        transaction['delivery_country'] = val
      end
      if key == 'DeliveryPhone' then
        transaction['delivery_phone'] = val
      end
    end
    transaction['tenant_id'] = tenant.id
    @transaction = Transaction.new(transaction)
    @transaction.save!
      redirect_to("/transactions/payment_done/"+@transaction.id.to_s)
  end

  private

  def is_superuser?
    unless current_user.typeofuser == "superuser" then
      if current_user.typeofuser == "admin" then
        redirect_to("/courses")
      elsif current_user.typeofuser == "learner" then
        redirect_to("/mycourses")
      end
    end
  end

end
