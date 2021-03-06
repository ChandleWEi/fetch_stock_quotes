static_propers =
    symbol: 's',
    name: 'n',
    last_trade_price_only: 'l1',
    last_trade_date: 'd1',
    last_trade_time: 't1',
    change_with_percent_change: 'c',
    change: 'c1',
    previous_close: 'p',
    change_in_percent: 'p2',
    open: 'o',
    day_low: 'g',
    day_high: 'h',
    volume: 'v',
    last_trade_with_time: 'l',
    day_range: 'm',
    ticker_trend: 't7',
    ask: 'a',
    average_daily_volume: 'a2',
    bid: 'b',
    bid_size: 'b4'

extend_propers = 
    symbol: 's',
    name: 'n',
    fifty_two_week_range: 'w',
    change_from_52_week_low: 'j5',
    percent_change_from_52_week_low: 'j6',
    change_from_52_week_high: 'k4',
    percent_change_from_52_week_high: 'k5',
    earnings_per_share: 'e',
    short_ratio: 's7',
    p_e_ratio: 'r',
    dividend_pay_date: 'r1',
    ex_dividend_date: 'q',
    dividend_per_share: 'd',
    dividend_yield: 'y',  
    one_yr_target_price: 't8',
    market_capitalization: 'j1',  
    eps_estimate_current_year: 'e7',
    eps_estimate_next_year: 'e8',
    eps_estimate_next_quarter: 'e9',
    peg_ratio: 'r5',
    price_eps_estimate_current_year: 'r6',
    price_eps_estimate_next_year: 'r7',
    book_value: 'b4',
    ebitda: 'j4',
    fifty_day_moving_average: 'm3',
    two_hundred_day_moving_average: 'm4',
    change_from_200_day_moving_average: 'm5',
    percent_change_from_200_day_moving_average: 'm6',
    change_from_50_day_moving_average: 'm7',
    percent_change_from_50_day_moving_average: 'm8',
    shares_owned: 's1',
    price_paid: 'p1',
    commission: 'c3',
    holdings_value: 'v1',
    day_value_change: 'w1',
    trade_date: 'd2',
    holdings_gain_percent: 'g1',
    annualized_gain: 'g3',
    holdings_gain: 'g4',
    stock_exchange: 'x',
    high_limit: 'l2',
    low_limit: 'l3',
    notes: 'n4',
    fifty_two_week_low: 'j',
    fifty_two_week_high: 'k',
    more_info: 'i'

realtime_propers = 
    symbol: 's',
    name: 'n',
    ask_real_time: 'b2',
    bid_real_time: 'b3',
    change: 'c1',
    change_real_time: 'c6',
    after_hours_change_real_time: 'c8',
    holdings_gain_percent_real_time: 'g5',
    holdings_gain_real_time: 'g6',
    order_book_real_time: 'i5',
    market_cap_real_time: 'j3',
    last_trade_real_time_with_time: 'k1',
    change_percent_real_time: 'k2',
    day_range_real_time: 'm2',
    p_e_ratio_real_time: 'r2',
    holdings_value_real_time: 'v7',
    day_value_change_real_time: 'w4'

query_options = 
  #uri: "http://finance.yahoo.com/d/quotes.csv?s=%s&f=snj1l1cpmwa2s7rr6r7r5t8db4"
  #[:symbol,:last_trade_price_only,:change,:change_in_percent]
  uri: "http://finance.yahoo.com/d/quotes.csv?s=%s&f=sl1c1p2"
  port: 80

exports.static_propers = static_propers
exports.extend_propers = extend_propers
exports.realtime_propers = realtime_propers
exports.query_options = query_options
