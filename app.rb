# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

MEMO_FILE = 'memos.json'

def load_memos
  return [] unless File.exist?(MEMO_FILE)

  JSON.parse(File.read(MEMO_FILE), symbolize_names: true)
end

def save_memos(memos)
  File.write(MEMO_FILE, JSON.pretty_generate(memos))
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title].strip
  content = params[:content].strip

  if title.empty?
    @error = 'タイトルを入力してください'
    erb :new
  else
    memos = load_memos
    new_memo = { id: SecureRandom.uuid, title: title, content: content }
    memos << new_memo
    save_memos(memos)
    redirect '/memos'
  end
end

get '/memos/:id' do
  memos = load_memos
  @memo = memos.find { |m| m[:id] == params[:id] }
  halt 404, 'メモが見つかりません' unless @memo
  erb :show
end

get '/memos/:id/edit' do
  memos = load_memos
  @memo = memos.find { |m| m[:id] == params[:id] }
  halt 404, 'メモが見つかりません' unless @memo
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  memo = memos.find { |m| m[:id] == params[:id] }
  halt 404, 'メモが見つかりません' unless memo

  title = params[:title].strip
  content = params[:content].strip

  if title.empty?
    @error = 'タイトルを入力してください'
    @memo = memo
    erb :edit
  else
    memo[:title] = title
    memo[:content] = content
    save_memos(memos)
    redirect "/memos/#{params[:id]}"
  end
end

delete '/memos/:id' do
  memos = load_memos
  memo = memos.find { |m| m[:id] == params[:id] }
  halt 404, 'メモが見つかりません' unless memo

  memos.delete(memo)
  save_memos(memos)
  redirect '/memos'
end
