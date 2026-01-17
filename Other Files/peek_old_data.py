import pandas as pd
import os

def peek_csv(file_path):
    print(f"\n--- {os.path.basename(file_path)} ---")
    try:
        df = pd.read_csv(file_path)
        print(f"Shape: {df.shape}")
        print(df.head())
        if 'date' in df.columns:
            df['date'] = pd.to_datetime(df['date'])
            print(f"Date range: {df['date'].min()} to {df['date'].max()}")
        if 'signup_date' in df.columns:
            df['signup_date'] = pd.to_datetime(df['signup_date'])
            print(f"Signup Date range: {df['signup_date'].min()} to {df['signup_date'].max()}")
    except Exception as e:
        print(f"Error reading {file_path}: {e}")

old_dir = "old dataset"
files = ["customers.csv", "orders.csv", "marketing_spend.csv", "website_sessions.csv"]

for f in files:
    if os.path.exists(os.path.join(old_dir, f)):
        peek_csv(os.path.join(old_dir, f))

# Check temporal integrity
try:
    customers = pd.read_csv(os.path.join(old_dir, "customers.csv"))
    orders = pd.read_csv(os.path.join(old_dir, "orders.csv"))
    
    customers['signup_date'] = pd.to_datetime(customers['signup_date'])
    orders['order_date'] = pd.to_datetime(orders['order_date'])
    
    merged = orders.merge(customers, on='customer_id')
    violations = merged[merged['order_date'] < merged['signup_date']]
    print(f"\nTemporal violations (order_date < signup_date): {len(violations)}")
    if len(violations) > 0:
        print(violations[['customer_id', 'signup_date', 'order_date']].head())
except Exception as e:
    print(f"Error checking integrity: {e}")
