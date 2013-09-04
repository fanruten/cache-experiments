#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'rubygems/package_task'
require 'rubygems/specification'
require 'date'
require 'webrick'
require 'json'

class String
  def is_numeric?
    Float(self)
    true
  rescue
    false
  end
end

def create_not_found_error
  return create_error(404, "Not found")
end

def create_error(error_code, message)
  data = {
    error: {
      code: error_code,
      message: message
    }
  }
  return data
end


def create_data
  data = {
    data: [
      {
        id: "categoryId1",
        title: "Ноутбуки, планшеты и компьютеры",
        picture: "http://key.ru/images/item_images/item_8046b/notebook.jpg",
        description: "",
        position: 123456789,
        parent_id: "",
        counters: {
          children: 2,
          products: 2
        }
      },
      {
        id: "categoryId2",
        title: "Ноутбуки",
        picture: "http://key.ru/images/item_images/item_8046b/notebook.jpg",
        description: "портативный персональный компьютер",
        position: 123456789,
        parent_id: "categoryId1",
        counters: {
          children: 1,
          products: 2
        }
      }
    ]
  }
  return data
end

class LastModifiedHandler < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
        response.status = 200
        response['Content-Type'] = "application/json; charset=utf-8"
        response['Last-Modified'] = "2013-09-05T01:29:41+04:00"
     
        if request['If-Modified-Since'] == response['Last-Modified']
            response.status = 304
        else
            data = create_data
            response.body = data.to_json
        end
        p "Return response: #{response}"
  end
end

class CacheControlHandler < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
        response.status = 200
        response['Content-Type'] = "application/json; charset=utf-8"
        response['Cache-Control'] = "public, max-age=6000000"
        
        data = create_data
        response.body = data.to_json
        p "Return response: #{response}"
    end
end

class EtagHandler < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
        response.status = 200
        response['Content-Type'] = "application/json; charset=utf-8"
        response['ETag'] = "686897696a7c876b7e"
        
        if request['If-None-Match'] == response['ETag']
            response.status = 304
            else
            data = create_data
            response.body = data.to_json
        end
        p "Return response: #{response}"
    end
end


if $0 == __FILE__ then
  server = WEBrick::HTTPServer.new(:Port => 8000)
  server.mount "/api/lm", LastModifiedHandler
  server.mount "/api/cc", CacheControlHandler
  server.mount "/api/et", EtagHandler
  trap "INT" do server.shutdown end
  server.start
end
