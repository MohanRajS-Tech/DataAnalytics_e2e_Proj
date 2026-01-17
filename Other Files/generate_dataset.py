import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os
import random

# Set seed for reproducibility
np.random.seed(42)
random.seed(42)

# Configuration
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2025, 12, 31)
COUNTRIES = ['NL', 'DE']
CHANNELS = ['Organic', 'Paid Search', 'Email', 'Social']
CATEGORIES = {
    'Electronics': {'base_price': 450, 'margin': 0.15},
    'Fashion': {'base_price': 80, 'margin': 0.40},
    'Home': {'base_price': 150, 'margin': 0.25},
    'Sports': {'base_price': 120, 'margin': 0.30}
}

# Seasonality Multipliers (Monthly)
SEASONALITY = {
    1: 0.7, 2: 0.8, 3: 1.0, 4: 1.1, 5: 1.0, 6: 1.2,
    7: 1.3, 8: 1.1, 9: 1.0, 10: 1.2, 11: 2.5, 12: 2.2
}

def generate_calendar():
    dates = pd.date_range(START_DATE, END_DATE, freq='D')
    df = pd.DataFrame({'date': dates})
    df['month'] = df['date'].dt.month
    df['year'] = df['date'].dt.year
    df['seasonality_factor'] = df['month'].map(SEASONALITY)
    return df

def generate_marketing_spend(calendar):
    records = []
    for _, row in calendar.iterrows():
        # Daily variance
        base_factor = row['seasonality_factor'] * (1 + np.random.normal(0, 0.1))
        
        # Spend logic by channel
        # Paid Search: High, consistent but seasonal
        ps_spend = 500 * base_factor * (1 + np.random.normal(0, 0.05))
        records.append({'date': row['date'], 'channel': 'Paid Search', 'spend': round(ps_spend, 2)})
        
        # Social: Low base, spiky
        is_spike = random.random() < 0.1
        social_spend = (200 if is_spike else 50) * base_factor * (1 + np.random.normal(0, 0.2))
        records.append({'date': row['date'], 'channel': 'Social', 'spend': round(social_spend, 2)})
        
        # Email: Low cost, fixed overhead
        email_spend = 30 * (1 if row['date'].day % 4 == 0 else 0) # Periodic campaigns
        if email_spend > 0:
            records.append({'date': row['date'], 'channel': 'Email', 'spend': round(email_spend, 2)})
            
        # Organic: Zero spend (mostly)
    
    # Controlled Messiness: Missing spend days
    spend_df = pd.DataFrame(records)
    spend_df = spend_df.sample(frac=0.98) # 2% missing days
    
    # Mixed Case / Naming Messiness
    def messy_channel(c):
        if random.random() < 0.05:
            return c.replace(" ", "")
        return c
    spend_df['channel'] = spend_df['channel'].apply(messy_channel)
    
    return spend_df

def generate_sessions(calendar, spend):
    # Organic traffic (baseline)
    organic_sessions = calendar.copy()
    organic_sessions['channel'] = 'Organic'
    organic_sessions['sessions'] = (1000 * organic_sessions['seasonality_factor'] * (1 + np.random.normal(0, 0.05))).astype(int)
    
    # Paid traffic (driven by spend)
    # Merge spend back to calendar to handle missing days
    paid_traffic = spend.merge(calendar[['date', 'seasonality_factor']], on='date')
    
    # Efficiency by channel
    efficiency = {'Paid Search': 0.8, 'Social': 1.5, 'Email': 10.0}
    
    # Use messy naming in efficiency lookup (handle both)
    def get_eff(c):
        clean = "Paid Search" if "PaidSearch" in c else c
        return efficiency.get(clean, 1.0)

    paid_traffic['sessions'] = (paid_traffic['spend'] * paid_traffic['channel'].apply(get_eff) * (1 + np.random.normal(0, 0.1))).astype(int)
    
    sessions_df = pd.concat([organic_sessions[['date', 'channel', 'sessions']], 
                             paid_traffic[['date', 'channel', 'sessions']]])
    return sessions_df

def generate_customers_and_orders(sessions):
    customers = []
    orders = []
    cust_id_counter = 1
    order_id_counter = 1
    
    # Probabilities
    SIGNUP_PROB = 0.05
    CONV_PROBS = {
        'Organic': 0.02,
        'Paid Search': 0.015,
        'Email': 0.08,
        'Social': 0.01
    }
    
    # Category weights
    cat_list = list(CATEGORIES.keys())
    cat_weights = [0.2, 0.4, 0.2, 0.2] # Fashion is popular
    
    # Process day by day to ensure temporal integrity
    dates = sorted(sessions['date'].unique())
    active_customers = [] # list of dicts: {id, signup_date, total_orders}
    
    for dt in dates:
        dt_pd = pd.to_datetime(dt)
        day_sessions = sessions[sessions['date'] == dt]
        
        for _, s_row in day_sessions.iterrows():
            chan = s_row['channel']
            clean_chan = "Paid Search" if "PaidSearch" in chan else chan
            
            # 1. Signups
            num_signups = int(s_row['sessions'] * SIGNUP_PROB * (1 + np.random.normal(0, 0.1)))
            for _ in range(num_signups):
                customers.append({
                    'customer_id': cust_id_counter,
                    'signup_date': dt_pd.date(),
                    'country': random.choice(COUNTRIES),
                    'channel': chan
                })
                active_customers.append({'id': cust_id_counter, 'signup_date': dt_pd.date(), 'orders': 0})
                cust_id_counter += 1
            
            # 2. Orders from New Customers (Same day conversion)
            # This happens during the session
            num_new_orders = int(s_row['sessions'] * CONV_PROBS.get(clean_chan, 0.02))
            # Pick from people who just signed up or general pool? 
            # Let's say a fraction of sessions results in an order
            for _ in range(num_new_orders):
                # Pick a customer who already signed up (could be today or before)
                if not active_customers: continue
                
                # Biased towards new recruits for "conversion" sessions, 
                # but we'll allow repeat orders separately
                # To keep it simple: any session can be an order from an existing user
                target = random.choice(active_customers)
                
                # Temporal Check: order_date >= signup_date
                if dt_pd.date() < target['signup_date']: continue
                
                cat = np.random.choice(cat_list, p=cat_weights)
                base = CATEGORIES[cat]['base_price']
                
                # Discount logic
                discount = 0
                if clean_chan == 'Paid Search': discount = 0.1 # Competitive
                if dt_pd.month in [11, 12]: discount += 0.1 # Seasonal
                
                qty = np.random.choice([1, 2, 3], p=[0.85, 0.12, 0.03])
                price = base * (1 - discount)
                
                orders.append({
                    'order_id': order_id_counter,
                    'customer_id': target['id'],
                    'order_date': dt_pd.date(),
                    'category': cat,
                    'channel': chan,
                    'quantity': qty,
                    'base_price': base,
                    'revenue': round(price * qty, 2)
                })
                order_id_counter += 1
                target['orders'] += 1

    return pd.DataFrame(customers), pd.DataFrame(orders)

def main():
    print("Generating Calendar...")
    calendar = generate_calendar()
    
    print("Generating Marketing Spend...")
    spend = generate_marketing_spend(calendar)
    
    print("Generating Sessions...")
    sessions = generate_sessions(calendar, spend)
    
    print("Generating Customers & Orders (this may take a moment)...")
    customers, orders = generate_customers_and_orders(sessions)
    
    print("Generating Products...")
    products = pd.DataFrame([
        {'category': k, 'base_price': v['base_price'], 'margin': v['margin']}
        for k, v in CATEGORIES.items()
    ])
    
    # Create output directory
    os.makedirs('new_dataset', exist_ok=True)
    
    # Save files
    customers.to_csv('new_dataset/customers.csv', index=False)
    orders.to_csv('new_dataset/orders.csv', index=False)
    spend.to_csv('new_dataset/marketing_spend.csv', index=False)
    sessions.to_csv('new_dataset/website_sessions.csv', index=False)
    products.to_csv('new_dataset/products.csv', index=False)
    
    print(f"Dataset generated successfully in 'new_dataset' folder.")
    print(f"Customers: {len(customers)}")
    print(f"Orders: {len(orders)}")
    print(f"Sessions: {len(sessions)}")

if __name__ == "__main__":
    main()
