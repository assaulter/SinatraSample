# coding:utf-8
require 'active_record'
require 'sinatra'
require 'open-uri'
require 'nokogiri'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Student < ActiveRecord::Base
end

get '/' do
    @students = Student.all
    haml :index
end

get '/students.json' do
    content_type :json, :charset => 'utf-8'
    students = Student.all
    students.to_json
end

get '/title' do
    url = 'http://jpdirect.jp/system/'
    html = open(url).read

    doc = Nokogiri::HTML(html, url)
    doc.css('table.tbl-stripe').each do |node|
        p node.css('td').text
    end
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