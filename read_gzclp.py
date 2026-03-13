import pandas as pd
import sys

excel_file = '2.0_GZCLP 4-Day 12-Week.xlsx'

try:
    xl = pd.ExcelFile(excel_file)
    print("Sheets:", xl.sheet_names)
    
    for sheet in xl.sheet_names:
        df = xl.parse(sheet, nrows=20)
        print(f"\n--- Sheet: {sheet} ---")
        print(df.head(10).to_string())
except Exception as e:
    print("Error:", e)
