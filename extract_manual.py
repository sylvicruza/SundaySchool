import os
import re

log_path = r"C:\Users\cents\.gemini\antigravity\brain\de5ae0ad-e30c-4e46-8270-fcf14b8f351e\.system_generated\logs\overview.txt"
out_path = r"C:\Users\cents\AndroidStudioProjects\SundaySchool\assets\data\bible_study_manual_2026.md"

with open(log_path, 'r', encoding='utf-8') as f:
    text = f.read()

# We look for the start of the manual. Em dash or en dash might be there.
match = re.search(r'(# Opened Heavens Chapel [\—\-\–] Bible Study Manual 2026.*?)</USER_REQUEST>', text, re.DOTALL)
if match:
    manual_content = match.group(1).strip()
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w', encoding='utf-8') as out_f:
        out_f.write(manual_content)
    print("Manual extracted successfully!")
else:
    print("Could not find the manual in the log. Trying alternate regex...")
    match2 = re.search(r'(# Opened Heavens Chapel.*?)</USER_REQUEST>', text, re.DOTALL)
    if match2:
        with open(out_path, 'w', encoding='utf-8') as out_f:
            out_f.write(match2.group(1).strip())
        print("Manual extracted successfully with alt regex!")
    else:
        print("Failed totally")
