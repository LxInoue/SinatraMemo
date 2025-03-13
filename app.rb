require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

before do
  @app_name = 'メモアプリ'
end

def load_memos
  return [] unless File.exist?('memos.json')
  JSON.parse(File.read('memos.json'), symbolize_names: true)
end

get '/memos' do
  @memos = load_memos
  erb :index
end
