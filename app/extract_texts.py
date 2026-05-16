import os
import re
import json

directories = [
    '/Users/george/smivo/app/lib/features',
    '/Users/george/smivo/app/lib/shared/widgets'
]

exclude_exts = ['.g.dart', '.freezed.dart', '.gitkeep.dart']

def get_files():
    files = []
    for d in directories:
        for root, dirs, filenames in os.walk(d):
            # Only screens and widgets directories inside features
            if 'features' in d and not (root.endswith('/screens') or root.endswith('/widgets')):
                continue
            for f in filenames:
                if f.endswith('.dart') and not any(f.endswith(ext) for ext in exclude_exts):
                    files.append(os.path.join(root, f))
    return files

def parse_files(files):
    results = []
    text_pattern = re.compile(r"Text\(\s*['\"]([^'\"]{2,30})['\"]\s*,", re.DOTALL)
    
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            lines = content.split('\n')
            
            for m in text_pattern.finditer(content):
                text_str = m.group(1)
                
                if not text_str[0].isupper() or len(text_str.split()) > 4:
                    continue
                
                start_idx = m.start()
                line_no = content.count('\n', 0, start_idx) + 1
                
                open_parens = 0
                end_idx = start_idx + 4
                for i in range(start_idx + 4, len(content)):
                    if content[i] == '(':
                        open_parens += 1
                    elif content[i] == ')':
                        open_parens -= 1
                        if open_parens == 0:
                            end_idx = i + 1
                            break
                
                widget_code = content[start_idx:end_idx]
                widget_code_clean = re.sub(r'\s+', ' ', widget_code)
                
                if 'style:' in widget_code or 'style :' in widget_code:
                    results.append({
                        'file': f.replace('/Users/george/smivo/app/lib/', ''),
                        'line': line_no,
                        'text': text_str,
                        'code': widget_code_clean
                    })

    with open('/Users/george/smivo/app/extracted_headers.json', 'w') as out:
        json.dump(results, out, indent=2)

if __name__ == '__main__':
    files = get_files()
    parse_files(files)
