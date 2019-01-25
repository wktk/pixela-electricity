# frozen_string_literal: true

require './lib/electricity'
require 'optparse'
require 'pixela'

params = {}
opt = OptionParser.new
opt.on('-a', '--after=2018/01/01')
opt.on('-b', '--before=2018/12/31')
opt.parse!(ARGV, into: params)

electricity = Electricity.new
electricity.login(
  ENV['ELECTRICITY_LOGIN_URL'],
  ENV['ELECTRICITY_LOGIN_ID'],
  ENV['ELECTRICITY_PASSWORD'],
)

pixela = Pixela::Client.new(
  username: ENV['PIXELA_USERNAME'],
  token: ENV['PIXELA_TOKEN']
)

electricity.records(params).each do |date, kwh|
  next unless kwh
  pixela.update_pixel(graph_id: ENV['PIXELA_GRAPH_ID'], date: Date.parse(date), quantity: kwh)
end
