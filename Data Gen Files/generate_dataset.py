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
# Seasonality Multipliers (Monthly)
SEASONALITY = {
    1: 0.7, 2: 0.8, 3: 1.0, 4: 1.1, 5: 1.0, 6: 1.2,
    7: 1.3, 8: 1.1, 9: 1.0, 10: 1.2, 11: 2.5, 12: 2.2
}

# Expanded Product List (6-7 per category)
PRODUCTS_LIST = [
    # Electronics
    {'product_id': 1, 'product_name': 'Apex Smartphone', 'category': 'Electronics', 'base_price': 800, 'margin': 0.15},
    {'product_id': 2, 'product_name': 'Quantum Tablet', 'category': 'Electronics', 'base_price': 500, 'margin': 0.18},
    {'product_id': 3, 'product_name': 'Pro-Laptop', 'category': 'Electronics', 'base_price': 1200, 'margin': 0.12},
    {'product_id': 4, 'product_name': 'Noise-Cancel Headphones', 'category': 'Electronics', 'base_price': 250, 'margin': 0.25},
    {'product_id': 5, 'product_name': 'Smart Watch', 'category': 'Electronics', 'base_price': 300, 'margin': 0.20},
    {'product_id': 6, 'product_name': 'VR Headset', 'category': 'Electronics', 'base_price': 400, 'margin': 0.15},
    {'product_id': 7, 'product_name': '4K Monitor', 'category': 'Electronics', 'base_price': 350, 'margin': 0.20},
    
    # Fashion
    {'product_id': 8, 'product_name': 'Elite Denim Jacket', 'category': 'Fashion', 'base_price': 120, 'margin': 0.45},
    {'product_id': 9, 'product_name': 'Summer Silk Dress', 'category': 'Fashion', 'base_price': 90, 'margin': 0.50},
    {'product_id': 10, 'product_name': 'Wool Overcoat', 'category': 'Fashion', 'base_price': 200, 'margin': 0.40},
    {'product_id': 11, 'product_name': 'Graphic Tee', 'category': 'Fashion', 'base_price': 30, 'margin': 0.60},
    {'product_id': 12, 'product_name': 'Leather Boots', 'category': 'Fashion', 'base_price': 150, 'margin': 0.35},
    {'product_id': 13, 'product_name': 'Yoga Leggings', 'category': 'Fashion', 'base_price': 60, 'margin': 0.55},
    {'product_id': 14, 'product_name': 'Cashmere Scarf', 'category': 'Fashion', 'base_price': 80, 'margin': 0.50},
    
    # Home
    {'product_id': 15, 'product_name': 'Eco-Comfort Chair', 'category': 'Home', 'base_price': 250, 'margin': 0.30},
    {'product_id': 16, 'product_name': 'Modern Floor Lamp', 'category': 'Home', 'base_price': 120, 'margin': 0.35},
    {'product_id': 17, 'product_name': 'Bamboo Bed Sheets', 'category': 'Home', 'base_price': 100, 'margin': 0.40},
    {'product_id': 18, 'product_name': 'Ceramic Vase Set', 'category': 'Home', 'base_price': 70, 'margin': 0.45},
    {'product_id': 19, 'product_name': 'Wall Clock', 'category': 'Home', 'base_price': 45, 'margin': 0.50},
    {'product_id': 20, 'product_name': 'Scented Candle', 'category': 'Home', 'base_price': 25, 'margin': 0.60},
    {'product_id': 21, 'product_name': 'Standing Desk', 'category': 'Home', 'base_price': 450, 'margin': 0.25},
    
    # Sports
    {'product_id': 22, 'product_name': 'Pro-String Racket', 'category': 'Sports', 'base_price': 180, 'margin': 0.35},
    {'product_id': 23, 'product_name': 'Dumbbell Set', 'category': 'Sports', 'base_price': 120, 'margin': 0.30},
    {'product_id': 24, 'product_name': 'Yoga Mat', 'category': 'Sports', 'base_price': 50, 'margin': 0.45},
    {'product_id': 25, 'product_name': 'Premium Tennis Balls', 'category': 'Sports', 'base_price': 20, 'margin': 0.55},
    {'product_id': 26, 'product_name': 'Hydration Bottle', 'category': 'Sports', 'base_price': 35, 'margin': 0.50},
    {'product_id': 27, 'product_name': 'Resistance Bands', 'category': 'Sports', 'base_price': 25, 'margin': 0.55},
    {'product_id': 28, 'product_name': 'Running Shoes', 'category': 'Sports', 'base_price': 130, 'margin': 0.40}
]

CATEGORIES = list(set([p['category'] for p in PRODUCTS_LIST]))

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
        base_factor = row['seasonality_factor'] * (1 + np.random.normal(0, 0.1))
        ps_spend = 500 * base_factor * (1 + np.random.normal(0, 0.05))
        records.append({'date': row['date'], 'channel': 'Paid Search', 'spend': round(ps_spend, 2)})
        is_spike = random.random() < 0.1
        social_spend = (200 if is_spike else 50) * base_factor * (1 + np.random.normal(0, 0.2))
        records.append({'date': row['date'], 'channel': 'Social', 'spend': round(social_spend, 2)})
        email_spend = 30 * (1 if row['date'].day % 4 == 0 else 0)
        if email_spend > 0:
            records.append({'date': row['date'], 'channel': 'Email', 'spend': round(email_spend, 2)})
    spend_df = pd.DataFrame(records)
    spend_df = spend_df.sample(frac=0.98)
    def messy_channel(c):
        if random.random() < 0.05:
            return c.replace(" ", "")
        return c
    spend_df['channel'] = spend_df['channel'].apply(messy_channel)
    return spend_df

def generate_sessions(calendar, spend):
    organic_sessions = calendar.copy()
    organic_sessions['channel'] = 'Organic'
    organic_sessions['sessions'] = (1000 * organic_sessions['seasonality_factor'] * (1 + np.random.normal(0, 0.05))).astype(int)
    paid_traffic = spend.merge(calendar[['date', 'seasonality_factor']], on='date')
    efficiency = {'Paid Search': 0.8, 'Social': 1.5, 'Email': 10.0}
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
    SIGNUP_PROB = 0.05
    CONV_PROBS = {'Organic': 0.02, 'Paid Search': 0.015, 'Email': 0.08, 'Social': 0.01}
    
    # Product distribution within category (some products more popular)
    cat_weights = {'Electronics': 0.2, 'Fashion': 0.4, 'Home': 0.2, 'Sports': 0.2}
    
    dates = sorted(sessions['date'].unique())
    active_customers = []
    
    for dt in dates:
        dt_pd = pd.to_datetime(dt)
        day_sessions = sessions[sessions['date'] == dt]
        for _, s_row in day_sessions.iterrows():
            chan = s_row['channel']
            clean_chan = "Paid Search" if "PaidSearch" in chan else chan
            num_signups = int(s_row['sessions'] * SIGNUP_PROB * (1 + np.random.normal(0, 0.1)))
            for _ in range(num_signups):
                customers.append({'customer_id': cust_id_counter, 'signup_date': dt_pd.date(), 'country': random.choice(COUNTRIES), 'channel': chan})
                active_customers.append({'id': cust_id_counter, 'signup_date': dt_pd.date(), 'orders': 0})
                cust_id_counter += 1
            num_new_orders = int(s_row['sessions'] * CONV_PROBS.get(clean_chan, 0.02))
            for _ in range(num_new_orders):
                if not active_customers: continue
                target = random.choice(active_customers)
                if dt_pd.date() < target['signup_date']: continue
                
                # Pick Category
                cat = np.random.choice(list(cat_weights.keys()), p=list(cat_weights.values()))
                
                # Pick Product from Category
                cat_products = [p for p in PRODUCTS_LIST if p['category'] == cat]
                product = random.choice(cat_products)
                
                base = product['base_price']
                discount = 0
                if clean_chan == 'Paid Search': discount = 0.1
                if dt_pd.month in [11, 12]: discount += 0.1
                qty = np.random.choice([1, 2, 3], p=[0.85, 0.12, 0.03])
                price = base * (1 - discount)
                orders.append({
                    'order_id': order_id_counter,
                    'customer_id': target['id'],
                    'product_id': product['product_id'],
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
    print("Generating Customers & Orders...")
    customers, orders = generate_customers_and_orders(sessions)
    print("Generating Products...")
    products = pd.DataFrame(PRODUCTS_LIST)
    
    # Save files to workspace root
    customers.to_csv('customers.csv', index=False)
    orders.to_csv('orders.csv', index=False)
    spend.to_csv('marketing_spend.csv', index=False)
    sessions.to_csv('website_sessions.csv', index=False)
    products.to_csv('products.csv', index=False)
    
    print(f"Dataset updated successfully in root directory.")
    print(f"Customers: {len(customers)}, Orders: {len(orders)}, Products: {len(products)}")

if __name__ == "__main__":
    main()
