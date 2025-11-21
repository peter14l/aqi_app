#!/bin/bash

# Generate freezed models
echo "Generating freezed models..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Code generation completed successfully!"
