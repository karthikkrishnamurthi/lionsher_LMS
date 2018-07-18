class AnswersController < ApplicationController
  before_filter :login_required
 
  def index
    @answers = Answer.all
  end

  def show
    @answer = Answer.find(params[:id])
  end

  def new
    @answer = Answer.new
  end

  def edit
    @answer = Answer.find(params[:id])
  end

  def create
    @answer = Answer.new(params[:answer])
    @answer.save
    redirect_to(answers_url, :notice => 'Answer was successfully created.')
  end

  def update
    @answer = Answer.find(params[:id])
    @answer.update_attributes(params[:answer])
    redirect_to(answers_url, :notice => 'Answer was successfully updated.')
  end

  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy
    redirect_to(answers_url)
  end
end
