require 'rest-client'
require 'json'

USERNAME = 'direct'
PASSWORD = 'direct'
SERVER_NAME = 'http://queue.uat.vericity.net:15672'

response = RestClient::Request.execute method: :get, url: "#{SERVER_NAME}/api/queues/%2f/", user: USERNAME, password: PASSWORD
queues = JSON.parse response.body

ips = {}
queues.each do |q|
  name = q['name']
  if name[0..6] == 'amq.gen'
    today = Date.today
    idle_since = Date.parse q['idle_since']
    days_idle = today - idle_since
    ip = q['owner_pid_details']['peer_host']
    if !ips.has_key? ip
      ips[ip] = 0
    end
    ips[ip] += 1
    # if  days_idle > 1/1
      puts "#{q['name']} | #{days_idle.to_i} | #{q['owner_pid_details']['peer_host']}"
    # end
  end
end
ips.sort_by {|k, v| v}
ips.each_key do |k|
  puts "#{k}: #{ips[k]}"
end