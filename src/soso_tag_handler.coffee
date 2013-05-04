http = require 'http'
http.globalAgent.maxSockets = 10
request     = require 'request'
sprintf     = require('sprintf').sprintf
logger      = require './logger'
mysql       = require('./db').mysql
options     = require('./soso_request_properties').query_options
jsdom       = require 'jsdom'
env         = require './config/environment'

jsdom.defaultDocumentFeatures = 
  FetchExternalResources: false,
  ProcessExternalResources: false

fetch_tags_soso_score = (response, query) ->
  get_tags_total_count_sql = "select count(*) as count from tags"
  [tags_total_count, proxies_total_count] = [0, 0]
  mysql.query get_tags_total_count_sql, null, (err, results) ->
    if err
      consloe.log "[mysql error] Count tags failed for #{err}"
      return response.end()
    else
      tags_total_count = results[0].count
      console.log "[mysql tags_tags_total_count] #{tags_total_count} #{typeof tags_total_count}"
      [step_idx, completed_count, tag_count_per_request] = [0, 0, 1]

      get_proxies_total_count_sql = "select count(*) as count from http_proxies where available=true"
      mysql.query get_proxies_total_count_sql, null, (err, results) ->
        if err 
          consloe.log "[mysql error] Count proxies failed for #{err}"
        else
          proxies_total_count = results[0].count 
          console.log "[proxies_total_count]: #{proxies_total_count}"
          if proxies_total_count > 0
            for step in [0..tags_total_count-1] 
              get_tag_sql = "select name from tags order by id limit #{tag_count_per_request} offset #{step * tag_count_per_request}"
              mysql.query get_tag_sql, null, (err, tag_results) ->
                if err
                  console.log "[mysql error] Query tag failed for #{err}"
                else
                  get_proxy_sql = "select ip, port from http_proxies where available = true limit #{tag_count_per_request} offset #{step_idx * tag_count_per_request % proxies_total_count}"
                  mysql.query get_proxy_sql, null, (err, results) -> 
                    if err 
                      console.error "[mysql_error:fetch_tags_soso_score] can't find available proxy by #{err}"
                    else
                      proxy_ip = results[0].ip
                      proxy_port = results[0].port
                      console.info "[proxy_str]: #{proxy_ip}:#{proxy_port}"
                      request.get(
                        {
                          uri: "http://localhost:8888/single_tag_soso_rank?tag=#{tag_results[0].name}&proxy=#{proxy_ip}&port=#{proxy_port}",
                          timeout: 30000000
                        }, (error, res, body) ->
                             completed_count++
                             logger.info "[completed_count]: #{completed_count}"
                             update_all_tags_soso_score() if completed_count >= tags_total_count
                      )
                  step_idx++
    
  console.log "Request handler start was called"
  response.writeHead  200, {"Content-Type": "text/plain"}
  response.write 'Going to fetch tag score one by one.'
  response.end()

update_all_tags_soso_score = ->
  console.log "[tags:soso:ranks] all tags' soso rank updated" 
  update_tags_score_sql = "call prcd_update_tags_soso_score();"
  mysql.query update_tags_score_sql, null, (err, results) ->
    if err
      console.log "[mysql error] update tags soso score failed for #{err}"
    else
      console.log "tags soso score updated"

single_tag_soso_rank = (response, query) ->
  query_option = {}
  for str in query.split('&')
    [k,v] = str.split '='
    query_option[k] = v

  tag = query_option.tag
  console.info decodeURI(tag)

  dest_url = sprintf options.default_uri, tag
  logger.info "--- going to query #{dest_url}"

  update_sql = "update tags set soso_rank=?, updated_at=now() where name=?"

  request.get(
    { 
      uri: dest_url,
      timeout: 30000000, #默认超时时间设置为30000秒 
      proxy: "http://#{query_option.proxy}:#{query_option.port}"
      headers: {"User-Agent": "Safari 10.2"},
    },(error, res, body) ->
        if error 
          logger.error "[tag:fame:error] can't open #{dest_url}"
          response.end()
        else
          jsdom.env {html: body}, (error, window) ->
                                    if error 
                                      logger.error "[tag:fame:error] can't open #{dest_url} with #{query_option.proxy}:#{query_option.port}"
                                      response.end()
                                    else
                                      reg_pat =  /((\d{1,},?)+)/im
                                      #reg_pat =  /totalNum.*\s((\d{1,},?)+\s)/m
                                      match = reg_pat.exec body
                                      unless match == null 
                                        console.log "match: #{match}"
                                        console.log "match0: #{match[0]}"
                                        console.log "match0: #{match[1]}"
                                        score = match[1].replace(/,/,'')
                                        logger.info score
                                        mysql.query update_sql, [score, decodeURI(tag)], (err, results) ->
                                          if err
                                            consloe.log "[mysql error] update soso rank failed for #{err}"
                                          window.close()
                                          response.end()
                                      else
                                        logger.info "tag #{tag} total_num_not_found"
                                        window.close()
                                        response.end()
  )  

calc_top_hundred_score = (response, query) ->
  update_all_tags_soso_score()
  response.write("all tags soso score will be updated")
  response.end()

exports.single_tag_soso_rank = single_tag_soso_rank
exports.fetch_tags_soso_score = fetch_tags_soso_score
exports.calc_top_hundred_soso_score = calc_top_hundred_score
