class TestPatternsController < ApplicationController

  def index
    @test_patterns = TestPattern.find(:all)
  end

  def show
    @test_pattern = TestPattern.find(params[:id])
  end

  def new
    @test_pattern = TestPattern.new
  end

  def edit
    @test_pattern = TestPattern.find(params[:id])
  end

  def create
    @test_pattern = TestPattern.new(params[:test_pattern])
    @test_pattern.save
    redirect_to(test_patterns_url)
  end

  def update
    @test_pattern = TestPattern.find(params[:id])
    @test_pattern.update_attributes(params[:test_pattern])
    redirect_to(test_patterns_url)
  end

  def destroy
    @test_pattern = TestPattern.find(params[:id])
    @test_pattern.destroy
    redirect_to(test_patterns_url)
  end
end
