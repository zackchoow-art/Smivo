import os
import re

def remove_invalid_consts():
    base_dir = '/Users/george/smivo/app'
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if not file.endswith('.dart'): continue
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            # replace const Icon(... colors...) with Icon(... colors...)
            # We can use a regex
            new_content = re.sub(r'const\s+(Icon\([^)]*colors\.[^)]+\))', r'\1', content)
            new_content = re.sub(r'const\s+(SizedBox\([^)]*colors\.[^)]+\))', r'\1', new_content)
            new_content = re.sub(r'const\s+(BoxDecoration\([^)]*colors\.[^)]+\))', r'\1', new_content)
            new_content = re.sub(r'const\s+(TextStyle\([^)]*colors\.[^)]+\))', r'\1', new_content)
            new_content = re.sub(r'const\s+(CircularProgressIndicator\([^)]*colors\.[^)]+\))', r'\1', new_content)
            new_content = re.sub(r'const\s+(IconThemeData\([^)]*colors\.[^)]+\))', r'\1', new_content)
            
            if new_content != content:
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Fixed const in {file}")

if __name__ == '__main__':
    remove_invalid_consts()
