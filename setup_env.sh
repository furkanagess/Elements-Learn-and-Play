#!/bin/bash

# Environment Setup Script
# This script helps set up environment variables for the Flutter app

echo "🔧 Setting up environment configuration..."

# Check if .env file already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 1
    fi
fi

# Copy template to .env
echo "📋 Copying environment template..."
cp env.template .env

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "✅ Environment file created successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Edit .env file with your actual AdMob IDs"
    echo "2. Replace placeholder values with real values"
    echo "3. Never commit .env file to version control"
    echo ""
    echo "🔍 To edit the file:"
    echo "   nano .env"
    echo "   # or"
    echo "   code .env"
    echo ""
    echo "🚀 After editing, run:"
    echo "   flutter run"
else
    echo "❌ Failed to create environment file!"
    exit 1
fi

echo "🎉 Environment setup completed!"
