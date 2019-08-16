class TestsController < ApplicationController
  before_action :check_is_logged_in, except: %i[index]
  before_action :check_is_admin_permission, except: %i[index show]
  before_action :get_test, only: %i[show destroy edit update]

  def index
    @tests = Test.all.paginate(page: params[:page],
                               per_page: Settings.per_page_tests)
    render 'tests/admin/index' if current_user&.is_admin?
  end

  def show
    @questions = @test.questions.includes :answers
    render 'tests/admin/show' if current_user.is_admin?
  end

  def new
    @test = Test.new
  end

  def create
    @test = Test.new test_params
    if @test.save
      flash[:success] = t 'success_create', for_object: 'Test'
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @test.update_attributes(test_params)
      flash[:success] = t 'success_update', for_object: 'Test'
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
    @test.destroy
    flash[:success] = t '.success_delete', for_object: 'Test'
    redirect_to root_path
  end

  private

  def get_test
    @test = Test.find_by id: params[:id]
    return if @test

    flash[:danger] = t 'error_404'
    redirect_to root_path
  end

  def test_params
    test_attributes = [:name, :kind, :time,
                       questions_attributes:
                         [:id, :content, :_destroy, \
                          answers_attributes:
                            %i[id is_correct content _destroy]]]
    params.require(:test).permit(test_attributes)
  end
end
