#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'

require 'sqlite3'
require 'yaml'

dbconfig = YAML::load(File.open('config/database.yml'))[ENV['ENV'] ? ENV['ENV'] : 'development']
puts dbconfig
ActiveRecord::Base.establish_connection(dbconfig)

# Primary key columns named "id" will be created automatically,
# but with ActiveRecord there's no special way to specify a
# foreign key.

ActiveRecord::Schema.define(:version => 001) do
  if table_exists? "layers"
    drop_table "layers"
  end
  create_table "layers", :force => true do |t|
    t.string   "layer", :null => false
    t.integer  "refreshInterval",  :default => 300
    t.integer  "refreshDistance",  :default => 300
    t.boolean  "fullRefresh",  :default => true
    t.string   "showMessage"
    t.string   "biwStyle"
  end

  if table_exists? "pois"
    drop_table "pois"
  end
  create_table "pois", :force => true do |t|
    t.integer :layer_id
    t.integer :icon_id
    t.integer :action_id
    t.integer :transform_id
    t.integer :ubject_id
    t.integer "york_id"
    t.string "title", :null => false
    t.string "description"
    t.string "footnote"
    t.float "lat", :null=> false
    t.float "lon", :null=> false
    t.string "imageURL"
    t.string "biwStyle",  :default => "classic"
    t.float "alt", :default => 0
    t.integer "doNotIndex",      :default => 0
    t.boolean "showSmallBiw",    :default => true
    t.boolean "showBiwOnClick",  :default => true
    t.string "poiType",         :null => false, :default => "geo"
  end

  if table_exists? "icons"
    drop_table "icons"
  end
  create_table "icons", :force => true do |t|
    t.string "label"
    t.string "url", :null => false
    t.integer "type", :null => false, :default => 0
  end

  if table_exists? "actions"
    drop_table "actions"
  end
  create_table "actions", :force => true do |t|
    t.string "poiID",           :null => false
    t.string "label",           :null => false
    t.string "uri",             :null => false
    t.string "contentType",     :default => "application/vnd.layar.internal"
    t.string "method",          :default => "GET"   # "GET", "POST"
    t.integer "activityType",    :deault => 1
    t.string "params"
    t.boolean "closeBiw",        :default => false
    t.boolean "showActivity",    :default => false
    t.string "activityMessage"
    t.boolean "autoTrigger",     :required => true, :default => false
    t.integer "autoTriggerRange"
    t.boolean "autoTriggerOnly", :default => false
  end

  if table_exists? "ubjects"
    drop_table "ubjects"
  end
  create_table "ubjects", :force => true do |t|
    t.string "url",             :null => false
    t.string "reducedUrl",      :null => false
    t.string "contentType",     :null => false
    t.float "size",            :null => false
  end

  if table_exists? "transforms"
    drop_table "transforms"
  end
  create_table "transforms", :force => true do |t|
    t.integer "rel",             :default => 0
    t.decimal "angle",           :size => [5, 2], :default => 0.00
    t.decimal "rotate_x",        :size => [2, 1], :default => 0.0
    t.decimal "rotate_y",        :size => [2, 1], :default => 0.0
    t.decimal "rotate_z",        :size => [2, 1], :default => 1.0
    t.decimal "translate_x",     :size => [2, 1], :default => 0.0
    t.decimal "translate_y",     :size => [2, 1], :default => 0.0
    t.decimal "translate_z",     :size => [2, 1], :default => 0.0
    t.decimal "scale",           :size => [12, 2], :default => 1.0, :null => false
  end

end

class Layer < ActiveRecord::Base
  has_many :pois
end

class Poi < ActiveRecord::Base
  has_one :layer
end

l = Layer.create(:layer => "Hello")
p = Poi.new(:title => "Foo", :lat => 10, :lon => 10)
l.pois << p