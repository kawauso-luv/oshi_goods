require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'json'
require 'dotenv/load'
# cloudinary関連
require 'cloudinary'
require 'cloudinary/uploader'
require 'cloudinary/utils'
# 設定用ファイル群
## api用ファイル
require "./utils/api/quantity_api.rb"
## 各種設定ファイル
require "./utils/permission.rb"
require "./utils/setting.rb"


enable :sessions

# app.rb呼び出し時に起動
before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"]
    config.api_key = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  end
  # カートに何が入っているかの連想配列
  if session[:cart] == nil
    session[:cart] = {}
  end
end

# トップページ表示
get '/' do
  @items = Item.all
  @category = @items.map{|item| item.category}.uniq
  @sum = @items.sum(:price)
  
  @category.each do |category|
    percent = @category.map{|category| @items.where(category: category).sum(:price).to_f / @sum.to_f * 100.round(2)}
    @percentages = []
    @percentages.push(percent)
  end
  
  
  erb :index
end

# 特定の商品ページ表示
get '/item/:id' do
  @item = Item.find(params[:id])
  erb :product
end

# 購入ありがとうページ表示
get '/thanks' do
  erb :thanks
end

# -----カート-----
# カートページ表示
get '/cart' do
  @cart = []
  @grand_total = 0
  # カート内の処理
  cart_item_ids = session[:cart].keys.map(&:to_i)
  items = Item.where(id: cart_item_ids)

  items.each do |item|
    key = item[:id].to_s
    
    if session[:cart][key]
      quantity = session[:cart][key][:quantity]
      total_price = item.price * quantity
      @cart.push({
        id: item.id,
        image_url: item.image_url,
        name: item.name,
        category: item.category,
        price: item.price,
        price_text: price_conversion(item.price),
        total_price: price_conversion(total_price)
      })
      @grand_total += total_price
    end
  end
  erb :cart
end

# カートの中身を追加
# /cart/add/:id のルーティングを記述しよう！

# カートの中の商品を削除
# /cart/delete/:id のルーティングを記述しよう！

## -----オーダー-----
# オーダー画面表示
get '/order' do
  TAX_PRICE = 330
  @grand_total = 0
  # 総計計算
  # ここを記述しよう！
  session[:cart].each do |item_id, item_data|
      item_price = item_data[:price]
      quantity = item_data[:quantity]
      @grand_total += item_price * quantity
    end
  # 税込み計算
  @grand_total_with_tax = price_conversion(@grand_total + TAX_PRICE)
  @grand_total = price_conversion(@grand_total)
  erb :order
end

# オーダー機能
post '/order' do
  order = Order.create()
  # カート内処理
  session[:cart].each do |item_id, item_data|
    quantity = item_data[:quantity]
    # order_itemsテーブルに情報を追加
    order_item = OrderItem.create(
      order_id: order.id,
      item_id: item_id,
      category: quantity
      )
    
    # 商品のストックを減らす
    item_saved_db = Item.find(item_id)
    item_saved_db.update(
      category: item_saved_db.category - order_item.category
      )
    
  end
  # カート内を空にする
  session[:cart] = {}
  redirect '/thanks'
end

## -----admin-----
# admin側の処理
get '/admin' do
  protected!
  erb :'admin/dashboard'
end

# admin: オーダーをすべて列挙するページ
get '/admin/orders' do
  protected!
  @items = Item.all
  @order_items = []
  OrderItem.all.each do |order_item|
    @order_items.push(
      {
        id: order_item.id,
        name: order_item.item.name,
        price: order_item.item.price,
        category: order_item.category,
        created_at: order_item.created_at
      }
    )
  end
  erb :'admin/orders'
end

# admin: 商品をすべて列挙するページ
get '/admin/products' do
  # protected!
  @items = Item.all.order(:id)
  erb :'admin/products'
end

# admin: 商品を追加する
post '/admin/post' do
  # protected!
  # params[:image]が空の場合の対処
  img_url = "/img/bilson.svg"
  if params[:image]
    image = params[:image]
    p image
    tempfile = image[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end
  # 商品の追加
  item = Item.create(
    name: params[:name],
    # description: params[:desciption],
    image_url: img_url,
    price: params[:price].to_i,
    category: params[:category])
  
  redirect '/admin'
end

post "/cart/add/:id" do
  id = params[:id]
  item = Item.find(id)
  
  unless session[:cart].include?(id)
    session[:cart][id] = {
      price: item.price,
      category: item.category,
      quantity: 1,
    }
  else
    item_data = session[:cart][id]
    unless item.category == item_data[:quantity]
      item_data[:quantity] += 1
    end
  end
  redirect "/cart"
end

post '/cart/delete/:id' do
  session[:cart].delete("#{params[:id]}")
  redirect '/cart'
end