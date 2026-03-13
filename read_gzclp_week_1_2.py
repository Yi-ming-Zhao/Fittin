import pandas as pd

excel_file = '2.0_GZCLP 4-Day 12-Week.xlsx'

try:
    xl = pd.ExcelFile(excel_file)
    df = xl.parse('Week 1-2', nrows=40)
    print(df.to_string(index=False))
except Exception as e:
    print("Error:", e)
