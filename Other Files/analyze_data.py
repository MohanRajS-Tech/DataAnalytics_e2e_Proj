import pandas as pd
import numpy as np
import json

def analyze():
    print("Loading data...")
    orders = pd.read_csv('orders.csv')
    customers = pd.read_csv('customers.csv')
    marketing = pd.read_csv('marketing_spend.csv')
    sessions = pd.read_csv('website_sessions.csv')
    products = pd.read_csv('products.csv')

    # Convert dates
    orders['order_date'] = pd.to_datetime(orders['order_date'])
    marketing['date'] = pd.to_datetime(marketing['date'])
    sessions['date'] = pd.to_datetime(sessions['date'])
    
    # Quarterly Revenue & Margin
    orders = orders.merge(products[['product_id', 'margin']], on='product_id')
    orders['profit'] = orders['revenue'] * orders['margin']
    orders['quarter'] = orders['order_date'].dt.to_period('Q')
    
    q_stats = orders.groupby('quarter').agg({
        'revenue': 'sum',
        'profit': 'sum',
        'order_id': 'count'
    }).reset_index()
    q_stats['margin_pct'] = q_stats['profit'] / q_stats['revenue']
    q_stats['aov'] = q_stats['revenue'] / q_stats['order_id']
    q_stats['quarter'] = q_stats['quarter'].astype(str)

    # Marketing Channel ROAS (Cleaned)
    marketing['channel'] = marketing['channel'].str.replace('PaidSearch', 'Paid Search').str.replace('Paidsearch', 'Paid Search')
    chan_spend = marketing.groupby('channel')['spend'].sum()
    
    orders['channel'] = orders['channel'].str.replace('PaidSearch', 'Paid Search').str.replace('Paidsearch', 'Paid Search')
    chan_rev = orders.groupby('channel')['revenue'].sum()
    
    chan_stats = pd.DataFrame({'spend': chan_spend, 'revenue': chan_rev})
    chan_stats['roas'] = chan_stats['revenue'] / chan_stats['spend']

    # Category Share by Quarter
    cat_q = orders.groupby(['quarter', 'category'])['revenue'].sum().unstack()
    cat_q_pct = cat_q.div(cat_q.sum(axis=1), axis=0)
    cat_q_pct.index = cat_q_pct.index.astype(str)

    # Customer Loyalty
    cust_orders = orders.groupby('customer_id')['order_id'].count().value_counts().sort_index()

    # Country-Category Mix
    orders_cust = orders.merge(customers[['customer_id', 'country']], on='customer_id')
    cat_country = orders_cust.groupby(['country', 'category'])['revenue'].sum().unstack()
    cat_country_pct = cat_country.div(cat_country.sum(axis=1), axis=0)

    # Retention by Signup Channel
    cust_orders_total = orders.groupby('customer_id')['order_id'].count().to_frame('total_orders')
    cust_loyalty = customers.merge(cust_orders_total, on='customer_id', how='left').fillna(0)
    loyalty_stats = cust_loyalty.groupby('channel')['total_orders'].mean()
    
    # Handle NaN for JSON
    chan_stats = chan_stats.fillna(0)
    
    results = {
        "quarterly_stats": q_stats.to_dict(orient='records'),
        "channel_roas": chan_stats.to_dict(orient='index'),
        "category_quarterly_pct": cat_q_pct.to_dict(orient='index'),
        "orders_per_customer": {str(k): int(v) for k, v in cust_orders.to_dict().items()},
        "country_category_pct": cat_country_pct.to_dict(orient='index'),
        "retention_by_channel": loyalty_stats.to_dict()
    }
    
    with open('analysis_results.json', 'w') as f:
        json.dump(results, f, indent=4, default=str)
    print("Results saved to analysis_results.json")

if __name__ == "__main__":
    analyze()
