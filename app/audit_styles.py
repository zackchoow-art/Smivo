import os
import re
from collections import defaultdict, Counter

directories = [
    '/Users/george/smivo/app/lib/features',
    '/Users/george/smivo/app/lib/shared/widgets'
]

exclude_exts = ['.g.dart', '.freezed.dart', '.gitkeep.dart']
exclude_dirs = ['providers']

def get_files():
    files = []
    for d in directories:
        for root, dirs, filenames in os.walk(d):
            if any(ex in root.split('/') for ex in exclude_dirs):
                continue
            for f in filenames:
                if f.endswith('.dart') and not any(f.endswith(ext) for ext in exclude_exts):
                    files.append(os.path.join(root, f))
    return files

def check_files(files):
    violations = []
    
    # regex to find TextStyle(...) spanning lines
    # we'll look for TextStyle(  or GoogleFonts.  or color: Color(  or color: Colors.
    
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            lines = content.split('\n')
            
            for i, line in enumerate(lines):
                line_no = i + 1
                rel_path = f.replace('/Users/george/smivo/app/lib/', '')
                
                # Check for High severity: raw TextStyle
                if 'TextStyle(' in line:
                    violations.append({
                        'file': rel_path,
                        'line': line_no,
                        'style': line.strip(),
                        'expected': 'Use typo.token.copyWith(...)',
                        'severity': 'High'
                    })
                
                # Check for High severity: GoogleFonts
                if 'GoogleFonts.' in line:
                    violations.append({
                        'file': rel_path,
                        'line': line_no,
                        'style': line.strip(),
                        'expected': 'Use typo.token',
                        'severity': 'High'
                    })
                
                # Check for Medium severity: hardcoded color in style
                # Usually: color: Color(0xFF...) or color: Colors.red
                if re.search(r'color:\s*Color\(', line) or re.search(r'color:\s*Colors\.[a-zA-Z_]', line):
                    # make sure it's inside some typography styling context or is a generic color usage 
                    # Actually, the prompt says "hardcoded color in text" (style: typo.X.copyWith(color: ...))
                    if 'color:' in line and ('Colors.' in line or 'Color(' in line):
                        # check if it's not transparent or white
                        if 'Colors.transparent' not in line:
                            violations.append({
                                'file': rel_path,
                                'line': line_no,
                                'style': line.strip(),
                                'expected': 'Use context.smivoColors...',
                                'severity': 'Medium'
                            })
                            
    return violations

if __name__ == '__main__':
    files = get_files()
    violations = check_files(files)
    
    severity_counts = Counter(v['severity'] for v in violations)
    
    feature_counts = Counter()
    for v in violations:
        parts = v['file'].split('/')
        if parts[0] == 'features':
            feature_counts[parts[1]] += 1
        else:
            feature_counts['shared'] += 1
            
    pattern_counts = Counter(v['style'] for v in violations)
    
    os.makedirs('/Users/george/smivo/app/audit_reports', exist_ok=True)
    with open('/Users/george/smivo/app/audit_reports/I3_body_text.md', 'w') as out:
        out.write("# Task I-3: Body Text & Hardcoded TextStyles Audit Report\n\n")
        
        out.write("## Summary\n")
        out.write(f"- Total violations found: {len(violations)}\n")
        out.write(f"- High severity (Raw TextStyle / GoogleFonts): {severity_counts.get('High', 0)}\n")
        out.write(f"- Medium severity (Hardcoded colors): {severity_counts.get('Medium', 0)}\n\n")
        
        out.write("## Violations by Feature Module\n")
        for feature, count in feature_counts.most_common():
            out.write(f"- **{feature}**: {count}\n")
        out.write("\n")
        
        out.write("## Top 10 Most Common Violation Patterns\n")
        for pattern, count in pattern_counts.most_common(10):
            out.write(f"1. `{pattern}` ({count} occurrences)\n")
        out.write("\n")
        
        out.write("## Complete Violations Table\n")
        out.write("| File | Line # | Hardcoded Style | What It Should Be | Severity |\n")
        out.write("|------|--------|-----------------|-------------------|----------|\n")
        for v in violations:
            out.write(f"| {v['file']} | {v['line']} | `{v['style'][:80]}` | {v['expected']} | {v['severity']} |\n")

    print(f"Report generated with {len(violations)} violations.")
