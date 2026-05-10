#!/usr/bin/env python3
import urllib.request
import os

url = "https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar"
output_path = os.path.join("android", "gradle", "wrapper", "gradle-wrapper.jar")

print(f"Downloading gradle-wrapper.jar from {url}...")
print(f"Saving to: {output_path}")

try:
    urllib.request.urlretrieve(url, output_path)
    if os.path.exists(output_path):
        file_size = os.path.getsize(output_path)
        print(f"✓ Success! Downloaded {file_size} bytes")
        print(f"✓ File saved to: {os.path.abspath(output_path)}")
    else:
        print("✗ Error: File was not created")
except Exception as e:
    print(f"✗ Error downloading: {e}")
