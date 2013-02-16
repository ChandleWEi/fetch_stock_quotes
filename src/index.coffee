server              =  require './server'
router              =  require './router'
quotes_handler      =  require './quotes_handler'
weibo_tag_handler   =  require './weibo_tag_handler'
proxy_handler       =  require './proxy_handler'

handle = { }

handle["/"]                       =     quotes_handler.start
handle["/fetch_all_quotes"]       =     quotes_handler.fetch_all_quotes
handle["/fetch_single_quote"]     =     quotes_handler.fetch_single_quote
handle["/tags_weibo_score"]       =     weibo_tag_handler.fetch_tags_weibo_score
handle["/single_tag_weibo_rank"]  =     weibo_tag_handler.single_tag_weibo_rank
handle["/validate_proxies"]       =     proxy_handler.validate_proxies

server.start(router.route, handle)
