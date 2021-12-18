require 'rails_helper'

RSpec.describe 'Todos requests', type: :request do
    describe('Test with common users') do
        before(:context) do
            @user_attr = FactoryBot.attributes_for(:user)
            @users = FactoryBot.create_list(:user, 5)
            @user = User.create!(@user_attr)
            sign_in @user
            @created_user_todos = FactoryBot.create_list(:todo, 10, user_id: @user.id)
            10.times do
              FactoryBot.create(:todo, user_id: @users.sample.id)
            end
            @created_user_todos_count = @created_user_todos.count 
            @initialCount = Todo.count
            @request_headers = @user.create_new_auth_token
        end
        let(:initial_count) { @initialCount }
    
        it 'return all todos from user' do
            get '/todos', headers: @request_headers
            expect(response).to have_http_status(:ok), "Got a #{response.status}: #{response.body}"
            expect(response.parsed_body.map{ |element| element.fetch("user_id") }).to all(eql(@user.id))
            expect(response.parsed_body.count).to eql(@created_user_todos_count)
        end
    
        describe 'TODO CRUD' do
            before(:all) do
                params = {
                    todo: {
                        title: 'My new todo',
                        description: "I must have fun tonight",
                    }
                }
                post '/todos', params: params, headers: @request_headers
                @todo_id = response.parsed_body.fetch("id")
                @new_todo_id = Todo.where.not("user_id": @user.id).first.id
            end
            it 'creates an todo' do
                expect(response).to have_http_status(:created)
                expect(Todo.count).to eql(initial_count + 1)
            end
    
            it 'returns todo by id' do
                get "/todos/#{@todo_id}", headers: @request_headers
                expect(response).to have_http_status(:ok)
                expect(response.parsed_body.fetch("id")).to eql(@todo_id)
            end
    
            it 'cant have access to other user todo' do
                get "/todos/#{@new_todo_id}", headers: @request_headers
                expect(response).to have_http_status(:forbidden)
            end
    
            it 'updates an todo' do
                params = {
                    todo: {
                        title: "Updated title",
                        description: "Updated description",
                    }
                }
    
                put "/todos/#{@todo_id}", params: params, headers: @request_headers
                expect(response).to have_http_status(:ok)
            end
    
            it 'cant update an todo from other user' do
                params = {
                    todo: {
                        title: "Updated title",
                        description: "Updated description",
                    }
                }
                put "/todos/#{@new_todo_id}", params: params, headers: @request_headers
                expect(response).to have_http_status(:forbidden)
            end
    
            it 'deletes an todo' do
                delete "/todos/#{@todo_id}", headers: @request_headers
                expect(response).to have_http_status(:no_content)
                expect(Todo.count).to eql(initial_count)
            end
            
            it 'cant delete todo from other user' do
                delete "/todos/#{@new_todo_id}", headers: @request_headers
                expect(response).to have_http_status(:forbidden)
            end
        end
    end

    describe('Test with user admin') do
        before(:context) do
            @user_attr = FactoryBot.attributes_for(:user, admin: true)
            @users = FactoryBot.create_list(:user, 5)
            @user_admin = User.create!(@user_attr)
            sign_in @user_admin
            @created_user_todos = FactoryBot.create_list(:todo, 5, user_id: @user_admin.id)
            10.times do
              FactoryBot.create(:todo, user_id: @users.sample.id)
            end
            @initialCount = Todo.count
            @request_headers = @user_admin.create_new_auth_token
        end
        it 'return all todos from all users' do
            get '/todos', headers: @request_headers
            expect(response).to have_http_status(:ok), "Got a #{response.status}: #{response.body}"
            expect(response.parsed_body.count).to eql(@initialCount)
        end

        describe 'TODO CRUD' do
            before(:all) do
                params = {
                    todo: {
                        title: 'My new todo',
                        description: "I must have fun tonight",
                    }
                }
                post '/todos', params: params, headers: @request_headers
                @todo_id = response.parsed_body.fetch("id")
                @new_todo = Todo.where.not("user_id": @user_admin.id).first
            end
            it 'creates an todo' do
                expect(response).to have_http_status(:created)
                expect(Todo.count).to eql(@initialCount + 1)
            end
    
            it 'returns todo by id' do
                get "/todos/#{@todo_id}", headers: @request_headers
                expect(response).to have_http_status(:ok)
                expect(response.parsed_body.fetch("id")).to eql(@todo_id)
            end
    
            it 'User admin can have access to other user todo' do
                get "/todos/#{@new_todo.id}", headers: @request_headers
                expect(response).to have_http_status(:ok)
            end
    
            it 'updates an todo' do
                params = {
                    todo: {
                        title: "Updated title",
                        description: "Updated description",
                    }
                }
    
                put "/todos/#{@todo_id}", params: params, headers: @request_headers
                expect(response).to have_http_status(:ok)
            end
    
            it 'User admin can update an todo from other user' do
                params = {
                    todo: {
                        title: "Updated title",
                        description: "Updated description",
                    }
                }
                put "/todos/#{@new_todo.id}", params: params, headers: @request_headers
                expect(response).to have_http_status(:ok)
            end
    
            it 'deletes an todo' do
                delete "/todos/#{@todo_id}", headers: @request_headers
                expect(response).to have_http_status(:no_content)
                expect(Todo.count).to eql(@initialCount)
            end
            
            it 'User admin can delete todo from other user' do
                delete "/todos/#{@new_todo.id}", headers: @request_headers
                expect(response).to have_http_status(:no_content)
            end
        end


    end

end