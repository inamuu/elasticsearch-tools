require 'open-uri'
require 'openssl'
require 'json'
require 'date'
require 'dotenv'

# Basic auth
Dotenv.load ".env"
USER = ENV["BASICUSER"]
PASS = ENV["BASICPASS"]

(Date.parse(ARGV[0])..Date.parse(ARGV[1])).each do |date|

  checkdate = date.strftime("%Y.%m.%d")
  puts "\e[33mCheckStart : #{checkdate}\e[0m"

  # Found URL
  esuri = "https://XXXXX/index-#{checkdate}/_count"
  begin
    html = open(esuri,{:http_basic_authentication => [USER, PASS],:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE}).read
    esresult = JSON.parse(html)
    escnt = esresult["count"]
  rescue => e
    puts e
    next
  end

  # AWS URL
  awsuri = "https://XXXXX/index-#{checkdate}/_count"

  begin
    html = open(awsuri,{ :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE}).read
    awsresult = JSON.parse(html)
    awscnt = awsresult["count"]
  rescue => e
    puts e
  end

  puts "\e[36mES\e[0m    : index count #{escnt}"
  puts "\e[36mAWS\e[0m   : index count #{awscnt}"

  if escnt == awscnt
    puts "\e[32mindex count OK\e[0m\n\n"
  else
    puts "\e[31mNG... Check index-#{checkdate} count\e[0m"
    exit
  end

end
