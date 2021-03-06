http = require 'http'
http.globalAgent.maxSockets = 50
request     = require 'request'
sprintf     = require('sprintf').sprintf
logger      = require './logger'
mysql       = require('./db').mysql
env         = require './config/environment'

Memcached = require 'memcached'
Memcached.config.poolSize = 25
memcached = new Memcached "#{env.MEMCACHED_HOST}:#{env.MEMCACHED_PORT}"

options = require('./yahoo_finance_properties').query_options

start = (response, query) ->
  console.log "Request handler start was called"
  response.writeHead  200, {"Content-Type": "text/plain"}
  response.write 'welcome to index.'
  response.end()

fetch_single_quote = (response, query) ->
  query = query.split('=')[1]
  console.log "Request handler quotes was called, will get quotes for #{query}"

  request.get sprintf(options.uri, query), (error, res, body) ->
    unless body == undefined
      # for line in body.replace(/"/g,'').split '\n'
      body.replace(/"/g,'').split('\n').forEach (line) ->
        line = line.trim()
        return if line == ''
        response.write line
        response.write "\n"
        stock_params = []
        ary = line.split(',')
        for i in [0...ary.length]
          stock_params.push "'#{ary[i]}'"
        logger.info "going to query database"
        sql = "call prcd_update_stock_quotes(#{stock_params.join(',')})"
        mysql.query sql, null, (err, results) ->
          if err
            console.log err 
            response.write "\n"
            response.write "insert into mysql failed for: #{err}"
          else
            console.log "memkey: #{env.MEMCACHED_NAMESPACE}:#{ary[0]}  #{ary[3]}"
            memcached.set "#{env.MEMCACHED_NAMESPACE}:#{ary[0]}", ary[3], env.STOCK_PRICE_EXPIRES, (error, result) ->
                                                    console.log "[cache:error:write] set price failed #{ary[0]}-#{ary[3]} caused by #{error}" if error

          console.log results
          response.write "\n"

    response.end()

fetch_all_quotes = (response, query) ->
  get_total_count_sql = "select count(*) as count from stocks"
  total_count = 0
  mysql.query get_total_count_sql, null, (err, results) ->
    if err
      consloe.log "[mysql error] Count stocks failed for #{err}"
      return response.end()
    else
      total_count = results[0].count
      console.log "[mysql quotes_total_count] #{total_count} #{typeof total_count}"
      [step, fetch_quotes_per_request] = [0, 50]
      loop 
        stock_tickers = []
        get_tickers_sql = "select ticker from stocks order by id limit #{fetch_quotes_per_request} offset #{step * fetch_quotes_per_request}"
        mysql.query get_tickers_sql, null, (err, results) ->
          if err
            console.log "[mysql error] Query stock quotes failed for #{err}"
          else
            for result in results
              stock_tickers.push result.ticker
            http.get("http://localhost:8888/fetch_single_quote?stock=#{stock_tickers.join(',')}",  (res) ->)
                .on 'error', (e) ->
                               console.log "[server error] batch fetch quotes failed caused by #{e}"
      
        step++
        break if step * fetch_quotes_per_request >= total_count
    
      response.end()

exports.start  = start
exports.fetch_all_quotes = fetch_all_quotes
exports.fetch_single_quote = fetch_single_quote

