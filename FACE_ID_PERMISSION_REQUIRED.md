# URGENT: Face ID Permission Setup

## 🚨 **Critical Step - Add Face ID Permission in Xcode**

You MUST add this permission in Xcode for Face ID to work:

### **Step-by-Step Instructions:**

1. **Open FitLifeAdvisorApp.xcodeproj in Xcode**
2. **Click on your project name** (FitLifeAdvisorApp) in the navigator
3. **Select the FitLifeAdvisorApp target**
4. **Click the "Info" tab**
5. **Under "Custom iOS Target Properties", click the + button**
6. **Add this EXACT entry:**
   - **Key**: `NSFaceIDUsageDescription`
   - **Type**: String
   - **Value**: `FitLife Advisor uses Face ID to securely authenticate and protect your personal fitness and health data.`

### **Alternative Method:**
1. **Right-click on your project**
2. **Add Files to "FitLifeAdvisorApp"**
3. **Create new file → Property List**
4. **Name it**: Info.plist
5. **Add the NSFaceIDUsageDescription key**

## ⚠️ **Without this permission, Face ID will NOT work!**

After adding the permission:
- Clean Build Folder (Cmd+Shift+K)
- Build and Run
- Face ID should now work properly
