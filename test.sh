#!/bin/bash

# Get the current PATH
current_path=$PATH

# Remove redundant Java paths
new_path=$(echo $current_path | sed 's|C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.13.11-hotspot\\bin;||g')
new_path=$(echo $new_path | sed 's|C:\\Program Files\\Eclipse Adoptium\\jdk-11.0.25.9-hotspot\\bin;||g')

# Add Flutter path to the beginning of the PATH
flutter_path="C:\\Users\\thisi\\fvm\\default\\bin;"
new_path="$flutter_path$new_path"

# Set the updated PATH to the user environment
export PATH=$new_path

# Verify if the path is updated correctly
echo "Updated PATH: $PATH"

# Optionally, you can save this new PATH permanently to the user's profile
echo "export PATH=$new_path" >> ~/.bashrc

# Verify Java, Flutter, Dart, Git versions after change
echo "Java Version:"
java -version

echo "Flutter Doctor:"
flutter doctor -v

echo "Git Version:"
git --version

echo "Dart Version:"
dart --version
