import pandas as pd
import numpy as np
import os

def verify_dataset():
    new_dir = "new_dataset"
    print(f"--- Verifying Dataset in {new_dir} ---")
    
    customers = pd.read_csv(os.path.join(new_dir, "customers.csv"))
    orders = pd.read_csv(os.path.join(new_dir, "orders.csv"))
    spend = pd.read_csv(os.path.join(new_dir, "marketing_spend.csv"))
    sessions = pd.read_csv(os.path.join(new_dir, "website_sessions.csv"))
    
    # 1. Temporal Integrity
    print("\n1. Checking Temporal Integrity...")
    customers['signup_date'] = pd.to_datetime(customers['signup_date'])
    orders['order_date'] = pd.to_datetime(orders['order_date'])
    
    merged = orders.merge(customers, on='customer_id', suffixes=('_order', '_signup'))
    violations = merged[merged['order_date'] < merged['signup_date']]
    print(f"Temporal violations (order_date < signup_date): {len(violations)}")
    
    # 2. Seasonality Check
    print("\n2. Checking Seasonality (Monthly Revenue)...")
    orders['month'] = orders['order_date'].dt.month
    monthly_rev = orders.groupby('month')['revenue'].sum()
    print("Monthly Revenue Distribution:")
    print(monthly_rev)
    # November/December should be high
    nov_dec = monthly_rev.loc[[11, 12]].mean()
    jan_feb = monthly_rev.loc[[1, 2]].mean()
    print(f"Nov/Dec Average Rev: {nov_dec:.2f}")
    print(f"Jan/Feb Average Rev: {jan_feb:.2f}")
    print(f"Peak-to-Trough Ratio: {nov_dec/jan_feb:.2f}x")
    
    # 3. Marketing Causality
    print("\n3. Checking Marketing-to-Session Correlation...")
    # Clean channel names for correlation check
    sessions['clean_channel'] = sessions['channel'].str.replace(" ", "")
    spend['clean_channel'] = spend['channel'].str.replace(" ", "")
    
    merged_impact = sessions.merge(spend, on=['date', 'clean_channel'])
    correlation = merged_impact['spend'].corr(merged_impact['sessions'])
    print(f"Correlation between Spend and Sessions (Paid Channels): {correlation:.4f}")
    
    # 4. Channel Specifics
    print("\n4. Channel Performance Metrics...")
    channel_metrics = orders.groupby('channel').agg({
        'revenue': 'mean',
        'order_id': 'count'
    }).rename(columns={'revenue': 'AOV', 'order_id': 'Order Count'})
    print(channel_metrics)

if __name__ == "__main__":
    verify_dataset()
