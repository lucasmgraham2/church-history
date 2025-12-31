import re
import json

# Path to your JSON file
input_path = r"c:/Users/lucas/Documents/GitHub/church-history/flutter_frontend/assets/data/church_history.json"
output_path = r"c:/Users/lucas/Documents/GitHub/church-history/flutter_frontend/assets/data/church_history_cleaned.json"

def remove_json_comments(text):
    # Remove all // ... comments
    return re.sub(r'\s*//.*', '', text)

def remove_duplicate_keys(obj):
    if isinstance(obj, dict):
        new_obj = {}
        for k, v in obj.items():
            if k not in new_obj:
                new_obj[k] = remove_duplicate_keys(v)
        return new_obj
    elif isinstance(obj, list):
        return [remove_duplicate_keys(i) for i in obj]
    else:
        return obj

def main():
    with open(input_path, 'r', encoding='utf-8') as f:
        raw = f.read()
    # Remove comments
    no_comments = remove_json_comments(raw)
    # Fix trailing commas (common after comment removal)
    no_trailing_commas = re.sub(r',\s*([}\]])', r'\1', no_comments)
    # Try to load JSON
    try:
        data = json.loads(no_trailing_commas)
    except Exception as e:
        print("JSON load error:", e)
        print("Try fixing remaining issues manually.")
        return
    # Remove duplicate keys recursively
    cleaned = remove_duplicate_keys(data)
    # Write cleaned JSON
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(cleaned, f, indent=2, ensure_ascii=False)
    print(f"Cleaned JSON written to {output_path}")

if __name__ == "__main__":
    main()
