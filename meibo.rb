# coding:utf-8
require 'active_record'
require 'sinatra'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Student < ActiveRecord::Base
end

get '/' do
    @students = Student.all
    haml :index
end

post '/new' do
    student = Student.new
    student.id = params[:id]
    student.name = params[:name]
    student.email = params[:email]
    student.save

    redirect '/'
end

delete '/delete' do
    student = Student.find(params[:id])
    student.destroy

    redirect '/'
end