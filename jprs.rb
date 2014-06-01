# coding:utf-8
require 'active_record'
require 'sinatra'
require 'open-uri'
require 'nokogiri'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class Maintenance < ActiveRecord::Base
end

get '/fetch' do
  url = 'http://jpdirect.jp/system/'
    html = open(url).read

    doc = Nokogiri::HTML(html, url)
    date , time = nil
    doc.css('table.tbl-stripe').each do |node|
        node.css('td').each_with_index do |item, index|
            date = Date.strptime(item.text.gsub(' ',''), "%Y年%m月%d日") if index%3 == 0
            if index%3 == 2
              time = item.text.gsub(' ','').split('〜')
              exec_save(date, time)
            end
        end
    end
end

private

def exec_save(date, time)
  return unless time.count == 2

  date_str = date.strftime('%Y/%m/%d/')
  start_datetime = date_str + DateTime.strptime(time[0], '%H:%M').strftime('%H:%M')
  end_datetime = date_str + DateTime.strptime(time[1], '%H:%M').strftime('%H:%M')

  begin
    target = Maintenance.find(date_str)  
    target.update_attribute(:start_datetime, start_datetime) unless target.start_datetime == start_datetime
    target.update_attribute(:end_datetime, end_datetime) unless target.end_datetime == end_datetime
  rescue Exception => e
    #見つからない場合はエクセプションを吐く TODO: このタイミングでメール投げていいんじゃないかな
    add_maintenance(date_str, start_datetime, end_datetime)
  end
end

def add_maintenance(date, start_datetime, end_datetime)
  Maintenance.create(date: date, start_datetime: start_datetime, end_datetime: end_datetime)
end