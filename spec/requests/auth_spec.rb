require 'rails_helper'

RSpec.describe 'Auth requests', type: :request do
    before(:all){
        params = {
            email: 'user@email.com',
            password: 'password',  
            password_confirmation: 'password'      
        }
        post '/auth/', params: params
    }
    it 'Signs up new user' do
        expect(response).to have_http_status(:success)
    end
    it 'Signs in user' do
        params = {
            email: 'user@email.com',
            password: 'password'
        }
        post '/auth/sign_in', params: params
        expect(response).to have_http_status(:success)
    end
end