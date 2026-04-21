import json
from datetime import datetime, timedelta
import random

end_date = datetime(2027, 1, 1)
current_price = 127
data = []

# Generate 365 days of data working backwards
for i in range(365):
    timestamp = (end_date - timedelta(days=i)).isoformat() + ".000Z"
    data.append({
        "price": round(current_price, 2),
        "timestamp": timestamp
    })
    
    # Simulate a daily walk (random movement between -10% and +10%)
    variation = 1 + random.uniform(-0.05, 0.05)
    current_price = current_price / variation

# Reverse to keep chronological order
data.reverse()

json_string = json.dumps(data, indent=2)

with open('WMT.json', 'w') as f:
    f.write(json_string)
