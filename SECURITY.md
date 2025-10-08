# Security Guidelines

## Environment Configuration

This project uses environment variables to manage sensitive data like AdMob IDs and API keys.

### Setup Instructions

1. **Copy the template file:**

   ```bash
   cp env.template .env
   ```

2. **Fill in your actual values in `.env`:**

   - Replace placeholder values with your actual AdMob IDs
   - Add your RevenueCat API keys
   - Configure Firebase settings if needed

3. **Never commit `.env` to version control:**
   - The `.env` file is already in `.gitignore`
   - Only commit `env.template` as a reference

### Environment Variables

#### AdMob Configuration

- `ADMOB_ANDROID_APP_ID`: Android AdMob Application ID
- `ADMOB_IOS_APP_ID`: iOS AdMob Application ID
- `ADMOB_ANDROID_BANNER_ID`: Android Banner Ad Unit ID
- `ADMOB_ANDROID_INTERSTITIAL_ID`: Android Interstitial Ad Unit ID
- `ADMOB_ANDROID_REWARDED_ID`: Android Rewarded Ad Unit ID
- `ADMOB_IOS_BANNER_ID`: iOS Banner Ad Unit ID
- `ADMOB_IOS_INTERSTITIAL_ID`: iOS Interstitial Ad Unit ID
- `ADMOB_IOS_REWARDED_ID`: iOS Rewarded Ad Unit ID

#### RevenueCat Configuration

- `REVENUECAT_ANDROID_API_KEY`: Android RevenueCat API Key
- `REVENUECAT_IOS_API_KEY`: iOS RevenueCat API Key

### Security Best Practices

1. **Never commit sensitive data** to version control
2. **Use different keys** for development and production
3. **Rotate API keys** periodically
4. **Monitor usage** of your API keys
5. **Use test ad IDs** during development
6. **Validate configuration** before deployment

### Development vs Production

- **Development**: Uses test ad IDs automatically when `kDebugMode = true`
- **Production**: Uses real ad IDs from environment variables
- **Fallback**: If environment variables are not set, uses default values

### File Structure

```
lib/core/config/
├── environment_config.dart    # Main configuration class
├── env_example.dart          # Example usage
└── secrets.dart              # (ignored) - for additional secrets

env.template                  # Template for environment variables
.env                         # (ignored) - actual environment file
```

### Troubleshooting

If ads are not loading:

1. Check if environment variables are set correctly
2. Verify AdMob IDs are valid
3. Ensure network connectivity
4. Check debug logs for configuration errors
