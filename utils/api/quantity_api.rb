# 小計を計算するメソッド
def calculate_price(id)
  item = session[:cart][id]
  price = item[:price]
  quantity = item[:quantity]
  
  return price * quantity
end

# カートの商品の購入数を変更するapi
post '/cart/update/quantity' do
  content_type :json
  request_body = JSON.parse(request.body.read)
  
  item_id = request_body['id']
  action = request_body['action']

  item = session[:cart][item_id]
  quantity = item[:quantity]

  case action
  when 'plus' then
    unless quantity == item[:stock]
      quantity += 1
    end
  when 'minus' then
    unless quantity == 1
      quantity -= 1
    end
  end
  
  item[:quantity] = quantity
  total_price = item[:price] * quantity
  
  grand_total = 0
  session[:cart].each do |id, _|
    grand_total += calculate_price(id)
  end
  
  { quantity: quantity, total_price: total_price, grand_total: grand_total }.to_json
end