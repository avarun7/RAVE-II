import pandas as pd

def load_csv(path):
    try:
        df = pd.read_csv(path)
        return df
    except Exception as e:
        print(f"Failed to load CSV: {e}")
        return pd.DataFrame()  # Return empty DataFrame on error
