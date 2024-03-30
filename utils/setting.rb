set :session_expiration, 86400

before do
  session.options[:expire_after] = settings.session_expiration
  
  path = request.fullpath.split("/").last
  case path
  when "order" then
    @page_name = "order"
  when "thanks" then
    @page_name = "thanks"
  when "admin" then
    @page_name = "admin"
  when "products" then
    @page_name = "products"
  when "orders" then
    @page_name = "orders"
  end
end

def price_conversion(price)
  return price.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')
end