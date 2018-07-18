class TestDetailsController < ApplicationController
  # GET /test_details
  # GET /test_details.json
  def index
    @test_details = TestDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @test_details }
    end
  end

  # GET /test_details/1
  # GET /test_details/1.json
  def show
    @test_detail = TestDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_detail }
    end
  end

  # GET /test_details/new
  # GET /test_details/new.json
  def new
    @test_detail = TestDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_detail }
    end
  end

  # GET /test_details/1/edit
  def edit
    @test_detail = TestDetail.find(params[:id])
  end

  # POST /test_details
  # POST /test_details.json
  def create
    @test_detail = TestDetail.new(params[:test_detail])

    respond_to do |format|
      if @test_detail.save
        format.html { redirect_to @test_detail, notice: 'Test detail was successfully created.' }
        format.json { render json: @test_detail, status: :created, location: @test_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @test_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_details/1
  # PUT /test_details/1.json
  def update
    @test_detail = TestDetail.find(params[:id])

    respond_to do |format|
      if @test_detail.update_attributes(params[:test_detail])
        format.html { redirect_to @test_detail, notice: 'Test detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_details/1
  # DELETE /test_details/1.json
  def destroy
    @test_detail = TestDetail.find(params[:id])
    @test_detail.destroy

    respond_to do |format|
      format.html { redirect_to test_details_url }
      format.json { head :no_content }
    end
  end
end
