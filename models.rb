require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class Item < ActiveRecord::Base
  has_many :order_items
end

class Order < ActiveRecord::Base
  has_many :order_items
end

class OrderItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :order
end
