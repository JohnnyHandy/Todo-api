require 'rails_helper'

RSpec.describe 'Todos rquests', type: :request do
    before(:context) do
        @created_todos = FactoryBot.create_list(:todo, 10)
        @initialCount = @created_todos.count
    end
    let(:created_todos) { @created_todos }
    let(:initial_count) { @initialCount }

    it 'return all todos' do
        get '/todos'
        expect(response).to have_http_status(:ok), "Got a #{response.status}: #{response.body}"
        expect(Todo.count).to eql(initial_count)
    end

    describe 'TODO CRUD' do
        before(:all) do
            params = {
                todo: {
                    title: 'My new todo',
                    description: "I must have fun tonight"    
                }
            }
            post '/todos', params: params
        end
        let (:todo_id) { response.parsed_body.fetch("id") }
        it 'creates an todo' do
            expect(response).to have_http_status(:created)
            expect(Todo.count).to eql(initial_count + 1)
        end

        it 'returns todo by id' do
            get "/todos/#{todo_id}"
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body.fetch("id")).to eql(todo_id)
        end

        it 'updates an todo' do
            params = {
                todo: {
                    title: "Updated title",
                    description: "Updated description"
                }
            }

            put "/todos/#{todo_id}", params: params
            puts response.parsed_body

            expect(response).to have_http_status(:ok)
        end

        it 'deletes an todo' do
            delete "/todos/#{todo_id}"
            expect(response).to have_http_status(:no_content)
            expect(Todo.count).to eql(initial_count)
        end
    
    end

end