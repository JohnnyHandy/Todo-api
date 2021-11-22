class TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo, only: [:show, :update, :destroy]
  before_action :check_owner, only: [:show, :update, :destroy]
  # GET /todos
  def index
    @user = current_user
    if @user
      @todos = @user.todos.all
      render json: @todos
    else
      head :unauthorized
    end
  end

  # GET /todos/1
  def show
    render json: @todo
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)
    @todo.user = current_user
    if @todo.save
      render json: @todo, status: :created, location: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todos/1
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todos/1
  def destroy
    @todo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:title, :description, :user_id)
    end
    
    def check_owner
      head :unauthorized unless current_user.id == @todo.user_id
    end
end
