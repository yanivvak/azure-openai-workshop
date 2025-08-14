#!/usr/bin/env python3
"""
Secret and API Key Scanner for Azure OpenAI Workshop
Scans the workspace for potential secrets, API keys, and sensitive information.
"""

import os
import re
import json
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple
from dataclasses import dataclass
from datetime import datetime


@dataclass
class SecretMatch:
    """Represents a potential secret found in a file"""
    file_path: str
    line_number: int
    line_content: str
    secret_type: str
    confidence: str  # HIGH, MEDIUM, LOW
    redacted_value: str


class SecretScanner:
    def __init__(self):
        self.patterns = {
            # Azure-specific patterns
            'azure_subscription_id': {
                'pattern': r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}',
                'confidence': 'HIGH',
                'description': 'Azure Subscription ID / GUID'
            },
            'azure_openai_key': {
                'pattern': r'sk-[a-zA-Z0-9]{20,}',
                'confidence': 'HIGH',
                'description': 'OpenAI API Key'
            },
            'azure_connection_string': {
                'pattern': r'(?i)InstrumentationKey=[a-f0-9-]{36}',
                'confidence': 'HIGH',
                'description': 'Azure Application Insights Connection String'
            },
            'azure_endpoint': {
                'pattern': r'https://[a-zA-Z0-9-]+\.(?:cognitiveservices|openai|services\.ai)\.azure\.com',
                'confidence': 'MEDIUM',
                'description': 'Azure Cognitive Services / OpenAI Endpoint'
            },
            
            # Generic patterns
            'api_key_generic': {
                'pattern': r'(?i)(?:api[_-]?key|apikey)\s*[:=]\s*["\']?([a-zA-Z0-9_-]{20,})["\']?',
                'confidence': 'HIGH',
                'description': 'Generic API Key'
            },
            'bearer_token': {
                'pattern': r'(?i)bearer\s+[a-zA-Z0-9_-]{20,}',
                'confidence': 'HIGH',
                'description': 'Bearer Token'
            },
            'aws_access_key': {
                'pattern': r'AKIA[0-9A-Z]{16}',
                'confidence': 'HIGH',
                'description': 'AWS Access Key'
            },
            'github_token': {
                'pattern': r'ghp_[a-zA-Z0-9]{36}',
                'confidence': 'HIGH',
                'description': 'GitHub Personal Access Token'
            },
            'private_key': {
                'pattern': r'-----BEGIN (?:RSA )?PRIVATE KEY-----',
                'confidence': 'HIGH',
                'description': 'Private Key'
            },
            'password_in_url': {
                'pattern': r'://[^:]+:[^@]+@',
                'confidence': 'MEDIUM',
                'description': 'Password in URL'
            },
            'jwt_token': {
                'pattern': r'eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*',
                'confidence': 'MEDIUM',
                'description': 'JWT Token'
            },
            
            # Environment variable patterns
            'env_secret': {
                'pattern': r'(?i)(?:secret|password|key|token)\s*[:=]\s*["\']?([a-zA-Z0-9_-]{8,})["\']?',
                'confidence': 'MEDIUM',
                'description': 'Potential Secret in Environment Variable'
            }
        }
        
        # Files to exclude from scanning
        self.exclude_patterns = {
            '.git',
            '__pycache__',
            '.vscode',
            'node_modules',
            '.terraform',
            '.venv',
            'env/',
            'venv/',
            '*.pyc',
            '*.log',
            '*.tmp',
            'secret_scanner.py'  # Don't scan ourselves
        }
        
        # File extensions to scan
        self.scan_extensions = {
            '.py', '.js', '.ts', '.json', '.yaml', '.yml', '.env', 
            '.txt', '.md', '.sh', '.bash', '.zsh', '.ps1', '.bat',
            '.ipynb', '.bicep', '.tf', '.tfstate', '.tfvars'
        }

    def should_exclude_file(self, file_path: Path) -> bool:
        """Check if file should be excluded from scanning"""
        file_str = str(file_path)
        
        # Check exclude patterns
        for pattern in self.exclude_patterns:
            if pattern in file_str:
                return True
        
        # Only scan files with specific extensions
        if file_path.suffix and file_path.suffix not in self.scan_extensions:
            return True
            
        return False

    def redact_secret(self, value: str, secret_type: str) -> str:
        """Redact sensitive values for safe display"""
        if len(value) <= 8:
            return "*" * len(value)
        
        if secret_type in ['azure_subscription_id', 'azure_connection_string']:
            # For GUIDs and connection strings, show first and last 4 chars
            return f"{value[:4]}...{value[-4:]}"
        elif secret_type in ['azure_endpoint']:
            # For endpoints, just show the pattern
            return re.sub(r'[a-zA-Z0-9-]+', '*****', value)
        else:
            # For other secrets, show first 4 chars
            return f"{value[:4]}{'*' * (len(value) - 4)}"

    def scan_file(self, file_path: Path) -> List[SecretMatch]:
        """Scan a single file for secrets"""
        matches = []
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                
            for line_num, line in enumerate(lines, 1):
                line_content = line.strip()
                
                # Skip empty lines and comments
                if not line_content or line_content.startswith('#'):
                    continue
                
                for secret_type, pattern_info in self.patterns.items():
                    pattern = pattern_info['pattern']
                    confidence = pattern_info['confidence']
                    
                    # Skip patterns if they're in example files
                    if 'example' in str(file_path).lower() and confidence == 'HIGH':
                        continue
                    
                    for match in re.finditer(pattern, line_content):
                        matched_value = match.group(0)
                        
                        # Skip obvious placeholders
                        if self.is_placeholder(matched_value):
                            continue
                        
                        redacted = self.redact_secret(matched_value, secret_type)
                        
                        matches.append(SecretMatch(
                            file_path=str(file_path),
                            line_number=line_num,
                            line_content=line_content,
                            secret_type=secret_type,
                            confidence=confidence,
                            redacted_value=redacted
                        ))
                        
        except Exception as e:
            print(f"Error scanning {file_path}: {e}")
            
        return matches

    def is_placeholder(self, value: str) -> bool:
        """Check if value is likely a placeholder"""
        placeholder_patterns = [
            r'your[-_]?(?:key|token|secret|password|endpoint)',
            r'(?:example|test|demo|placeholder)',
            r'xxx+',
            r'\*{3,}',
            r'\.{3,}',
            r'123456',
            r'[a-z]{8,}',  # All lowercase (likely placeholder)
        ]
        
        value_lower = value.lower()
        for pattern in placeholder_patterns:
            if re.search(pattern, value_lower):
                return True
        
        return False

    def scan_directory(self, root_path: Path) -> List[SecretMatch]:
        """Scan all files in directory recursively"""
        all_matches = []
        
        for file_path in root_path.rglob('*'):
            if file_path.is_file() and not self.should_exclude_file(file_path):
                matches = self.scan_file(file_path)
                all_matches.extend(matches)
        
        return all_matches

    def generate_report(self, matches: List[SecretMatch], output_format: str = 'text') -> str:
        """Generate a formatted report"""
        if output_format == 'json':
            return self.generate_json_report(matches)
        else:
            return self.generate_text_report(matches)

    def generate_text_report(self, matches: List[SecretMatch]) -> str:
        """Generate a human-readable text report"""
        report = []
        report.append("🔍 SECRETS AND API KEYS SCAN REPORT")
        report.append("=" * 50)
        report.append(f"Scan completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Total potential secrets found: {len(matches)}")
        report.append("")
        
        if not matches:
            report.append("✅ No secrets detected in the scanned files.")
            return "\n".join(report)
        
        # Group by confidence level
        high_confidence = [m for m in matches if m.confidence == 'HIGH']
        medium_confidence = [m for m in matches if m.confidence == 'MEDIUM']
        low_confidence = [m for m in matches if m.confidence == 'LOW']
        
        # Group by secret type
        by_type = {}
        for match in matches:
            if match.secret_type not in by_type:
                by_type[match.secret_type] = []
            by_type[match.secret_type].append(match)
        
        # Summary by type
        report.append("📊 SUMMARY BY SECRET TYPE")
        report.append("-" * 30)
        for secret_type, type_matches in sorted(by_type.items()):
            description = self.patterns[secret_type]['description']
            report.append(f"  {secret_type}: {len(type_matches)} matches - {description}")
        report.append("")
        
        # High confidence secrets
        if high_confidence:
            report.append("🚨 HIGH CONFIDENCE SECRETS (Immediate attention required)")
            report.append("-" * 60)
            for match in high_confidence:
                report.append(f"  File: {match.file_path}")
                report.append(f"  Line: {match.line_number}")
                report.append(f"  Type: {self.patterns[match.secret_type]['description']}")
                report.append(f"  Value: {match.redacted_value}")
                report.append(f"  Context: {match.line_content[:100]}...")
                report.append("")
        
        # Medium confidence secrets
        if medium_confidence:
            report.append("⚠️  MEDIUM CONFIDENCE SECRETS (Review recommended)")
            report.append("-" * 55)
            for match in medium_confidence:
                report.append(f"  File: {match.file_path}")
                report.append(f"  Line: {match.line_number}")
                report.append(f"  Type: {self.patterns[match.secret_type]['description']}")
                report.append(f"  Value: {match.redacted_value}")
                report.append("")
        
        # Recommendations
        report.append("🛡️  SECURITY RECOMMENDATIONS")
        report.append("-" * 30)
        report.append("1. Move all secrets to environment variables")
        report.append("2. Use Azure Key Vault for production secrets")
        report.append("3. Add sensitive files to .gitignore")
        report.append("4. Use Entra ID authentication when possible")
        report.append("5. Rotate any exposed API keys immediately")
        report.append("6. Enable secret scanning in your CI/CD pipeline")
        report.append("")
        
        # Files with secrets
        unique_files = set(match.file_path for match in matches)
        if unique_files:
            report.append("📁 FILES CONTAINING POTENTIAL SECRETS")
            report.append("-" * 40)
            for file_path in sorted(unique_files):
                file_matches = [m for m in matches if m.file_path == file_path]
                report.append(f"  {file_path} ({len(file_matches)} matches)")
        
        return "\n".join(report)

    def generate_json_report(self, matches: List[SecretMatch]) -> str:
        """Generate a JSON report"""
        report_data = {
            'scan_timestamp': datetime.now().isoformat(),
            'total_secrets': len(matches),
            'secrets': []
        }
        
        for match in matches:
            report_data['secrets'].append({
                'file_path': match.file_path,
                'line_number': match.line_number,
                'secret_type': match.secret_type,
                'description': self.patterns[match.secret_type]['description'],
                'confidence': match.confidence,
                'redacted_value': match.redacted_value,
                'line_context': match.line_content
            })
        
        return json.dumps(report_data, indent=2)


def main():
    parser = argparse.ArgumentParser(description='Scan for secrets and API keys')
    parser.add_argument('path', nargs='?', default='.', help='Path to scan (default: current directory)')
    parser.add_argument('--format', choices=['text', 'json'], default='text', help='Output format')
    parser.add_argument('--output', '-o', help='Output file (default: stdout)')
    parser.add_argument('--high-only', action='store_true', help='Show only high confidence matches')
    
    args = parser.parse_args()
    
    scanner = SecretScanner()
    scan_path = Path(args.path).resolve()
    
    print(f"🔍 Scanning {scan_path} for secrets and API keys...")
    matches = scanner.scan_directory(scan_path)
    
    if args.high_only:
        matches = [m for m in matches if m.confidence == 'HIGH']
    
    report = scanner.generate_report(matches, args.format)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(report)
        print(f"Report written to {args.output}")
    else:
        print(report)


if __name__ == '__main__':
    main()
