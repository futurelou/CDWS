
import pandas as pd
from sodapy import Socrata

client = Socrata("data.cdc.gov", None)

results = client.get("n8mc-b4w4", limit=100000)

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)

df = results_df.sample(20000)

