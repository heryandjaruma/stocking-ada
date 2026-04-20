import json
from datetime import datetime, timedelta
import random

end_date = datetime(2026, 4, 1)
current_equity = 99.0
data = []

# Generate 365 days of data working backwards
for i in range(365):
    timestamp = (end_date - timedelta(days=i)).isoformat() + ".000Z"
    data.append({
        "totalEquity": round(current_equity, 2),
        "timestamp": timestamp
    })
    
    # Simulate a daily walk (random movement between -1.2% and +1.2%)
    variation = 1 + random.uniform(-0.012, 0.012)
    current_equity = current_equity / variation

# Reverse to keep chronological order
data.reverse()

json_string = json.dumps(data, indent=2)

with open('equityHistory.json', 'w') as f:
    f.write(json_string)
