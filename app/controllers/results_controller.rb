class ResultsController < ApplicationController
  before_action :get_result, only: %i[show]
  before_action :get_test, only: %i[create index]
  before_action :save_result, :params_answers, only: %i[create]
  before_action :check_is_logged_in, :check_is_admin_permission, only: %i[index]

  def show
    @test = @result.test
    @questions = @test.questions.includes :answers
  end

  def create
    unless @params_answers[:answers].nil?
      @params_answers[:answers].each do |answer|
        save_result_answer answer, @result
      end
      update_result @result
    end
    flash[:success] = t '.result', score: @result.score
    redirect_to test_result_path(@test, @result)
  end

  def index
    @results = @test.results.includes :user
    @results = @results.paginate(page: params[:page])
  end

  private

  def get_result
    @result = Result.find_by id: params[:id]
    return if @result
  end

  def get_test
    @test = Test.find_by id: params[:test_id]
    return if @test

    flash[:danger] = t 'error_404'
    redirect_to root_path
  end

  def save_result
    @result = Result.create(user: current_user, test: @test)
  end

  def save_result_answer(answer, result)
    @result_answer = ResultAnswer.create(answer_id: answer, result: result)
  end

  def update_result(result)
    score = result.result_answers.inject(0) do |count, result_answer|
      count += 1 if result_answer.answer.is_correct?
      count
    end
    result.update_attribute :score, score
  end

  def params_answers
    @params_answers = params.permit(answers: [])
  end
end
