import json
import re
import os

with open('/Users/george/smivo/app/extracted_headers.json', 'r') as f:
    data = json.load(f)

# Keywords that suggest it's NOT a section header
exclude_keywords = [
    'submit', 'cancel', 'save', 'ok', 'yes', 'no', 'confirm', 'delete', 'remove',
    'retry', 'post', 'update', 'block', 'report', 'reject', 'approve',
    'failed', 'error', 'please', 'no ', 'not ', 'invalid', 'success', 'mark'
]

include_keywords = [
    'listing', 'evidence', 'history', 'info', 'transactions', 'storage', 
    'feedback', 'developer', 'display', 'description', 'period', 'deposit', 
    'seller', 'stats', 'location', 'campus', 'date', 'notifications', 
    'status', 'summary', 'details', 'settings', 'profile'
]

results = []
distinct_styles = set()

# Pre-load files to check for Icon
file_contents = {}

for item in data:
    filepath = '/Users/george/smivo/app/lib/' + item['file']
    if filepath not in file_contents:
        try:
            with open(filepath, 'r') as f:
                file_contents[filepath] = f.read().split('\n')
        except:
            file_contents[filepath] = []
            
    text_lower = item['text'].lower()
    
    if any(text_lower.startswith(k) or text_lower == k for k in exclude_keywords) and not 'history' in text_lower:
        continue
    
    code = item['code']
    
    style_source = ''
    token_used = ''
    font_size = ''
    weight = ''
    color_source = ''
    
    style_match = re.search(r'style:\s*([^,)]+)', code)
    if style_match:
        style_expr = style_match.group(1).strip()
        
        if 'TextStyle' in code:
            style_source = 'Hardcoded'
            fs_match = re.search(r'fontSize:\s*([\d.]+)', code)
            if fs_match: font_size = fs_match.group(1)
            fw_match = re.search(r'fontWeight:\s*(FontWeight\.[a-z0-9A-Z_]+)', code)
            if fw_match: weight = fw_match.group(1)
        elif 'typo' in style_expr or 'smivoTypo' in style_expr or 'textTheme' in style_expr:
            style_source = 'Theme Token'
            token_match = re.search(r'(typo|smivoTypo|textTheme)\.([a-zA-Z0-9_]+)', style_expr)
            if token_match: token_used = token_match.group(2)
            fw_match = re.search(r'fontWeight:\s*(FontWeight\.[a-z0-9A-Z_]+)', code)
            if fw_match: weight = fw_match.group(1)
        else:
            style_source = 'Other'
            token_used = style_expr
            
        color_match = re.search(r'color:\s*([^,)]+)', code)
        if color_match:
            color_source = color_match.group(1).strip()
    
    icon_val = 'No'
    icon_color = ''
    
    line_idx = item['line'] - 1
    # Check 15 lines above for an Icon widget
    lines = file_contents[filepath]
    start_look = max(0, line_idx - 15)
    context_str = '\n'.join(lines[start_look:line_idx+5])
    
    if 'Row(' in context_str or 'children:' in context_str:
        # Search backwards from Text for an Icon
        text_pos = context_str.find('Text(')
        icon_pos = context_str.rfind('Icon(', 0, text_pos)
        if icon_pos != -1:
            icon_val = 'Yes'
            # Check if icon has a color
            icon_snippet = context_str[icon_pos:text_pos]
            icon_color_match = re.search(r'color:\s*([^,)]+)', icon_snippet)
            if icon_color_match:
                icon_color = icon_color_match.group(1).strip()
    
    distinct_styles.add(f"{style_source} | {token_used} | {font_size} | {weight} | {color_source}")
    
    is_header = False
    if token_used in ['titleMedium', 'titleLarge', 'headlineSmall', 'headlineMedium', 'labelSmall', 'bodyLarge']:
        is_header = True
    if style_source == 'Hardcoded' and (font_size in ['16', '18', '20', '22', '24'] or 'bold' in weight.lower() or 'w700' in weight.lower() or 'w600' in weight.lower()):
        is_header = True
    
    if is_header or any(k in text_lower for k in include_keywords):
        results.append({
            'file': item['file'],
            'line': item['line'],
            'text': item['text'].replace('\n', ' '),
            'style_source': style_source,
            'token_used': token_used,
            'font_size': font_size,
            'weight': weight,
            'color_source': color_source,
            'icon': icon_val,
            'icon_color': icon_color
        })

os.makedirs('/Users/george/smivo/app/audit_reports', exist_ok=True)

with open('/Users/george/smivo/app/audit_reports/I2_section_subtitles.md', 'w') as out:
    out.write("# Task I-2: Section Subtitles Audit Report\n\n")
    
    out.write("## Summary\n")
    out.write(f"- Total section headers found: {len(results)}\n")
    out.write(f"- Using theme tokens correctly: {sum(1 for r in results if r['style_source'] == 'Theme Token')}\n")
    out.write(f"- Using hardcoded styles: {sum(1 for r in results if r['style_source'] == 'Hardcoded')}\n")
    
    # Calculate most common
    if len(results) > 0:
        import collections
        tokens = [r['token_used'] for r in results if r['token_used']]
        most_common = collections.Counter(tokens).most_common(1)
        if most_common:
            out.write(f"- Most common correct pattern: `typo.{most_common[0][0]}`\n")
        else:
            out.write("- Most common correct pattern: N/A\n")
    else:
        out.write("- Most common correct pattern: N/A\n")
        
    out.write("- Distinct style variations found:\n")
    for s in sorted(list(distinct_styles)):
        if s.strip() != '|  |  |  |':
            out.write(f"  - {s}\n")
    out.write("\n")
    
    out.write("## Per-file Table\n")
    out.write("| File | Line # | Section Text | Style Source | Token Used | Font Size | Weight | Color Source | Icon? | Icon Color |\n")
    out.write("|------|--------|--------------|--------------|------------|-----------|--------|--------------|-------|------------|\n")
    
    for r in results:
        out.write(f"| {r['file']} | {r['line']} | {r['text']} | {r['style_source']} | {r['token_used']} | {r['font_size']} | {r['weight']} | {r['color_source']} | {r['icon']} | {r['icon_color']} |\n")

print("Report generated.")
