server = require './server'
router = require './router'
request_handlers = require './request_handlers'
weibo_tag_handler = require './weibo_tag_handler'
proxy_handler = require './proxy_handler'

handle = { }

handle["/"] = request_handlers.start
handle["/quotes"] = request_handlers.quotes
handle["/fetch"]  = request_handlers.fetch_stocks
handle["/tags_weibo_score"] = weibo_tag_handler.fetch_tags_weibo_score
handle["/single_tag_weibo_rank"] = weibo_tag_handler.single_tag_weibo_rank

handle["/validate_proxies"] = proxy_handler.validate_proxies

server.start(router.route, handle)
