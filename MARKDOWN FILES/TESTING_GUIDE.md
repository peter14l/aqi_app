# Testing Guide - Multi-Agent AQI System

## 🚀 Quick Start

Your app is already running at `http://localhost:8080`. Here's how to test all the new features:

## 1️⃣ Setup First (REQUIRED)

### Add API Keys
Before testing, you MUST add your API keys to `.env`:

```bash
# Copy the example file
cp .env.example .env

# Edit .env and add:
WAQI_API_TOKEN=your_waqi_token_here
GEMINI_API_KEY=your_gemini_key_here
```

**Get API Keys:**
- WAQI: https://aqicn.org/data-platform/token/ (Free, instant)
- Gemini: https://aistudio.google.com/app/apikey (Free, instant)

### Restart the App
After adding keys:
```bash
# Stop current app (Ctrl+C in terminal)
# Then restart:
flutter run -d web-server --web-port=8080
```

## 2️⃣ Testing the UI Features

### A. Home Screen (Already Visible)
**What to see:**
- ✅ Current AQI circle (already there)
- ✅ Weather info (already there)
- ✅ **NEW: AI Insights Card** - Shows intelligent analysis
- ✅ **NEW: Recommendations Card** - Shows personalized advice

**How to test:**
1. Just look at the home screen
2. You should see two new cards below the weather
3. If API keys are set, they'll show real AI-generated content

### B. Chat Screen (NEW!)
**What it does:** Talk to the AI assistant

**How to access:**
1. Look at the bottom navigation bar (mobile) or sidebar (desktop)
2. Click the **chat icon** (💬)
3. You'll see the chat interface

**What to try:**
```
Type these questions:
- "What's the current AQI?"
- "Should I go for a run?"
- "What will the air quality be tomorrow?"
- "What if traffic increases by 50%?"
```

**What you'll see:**
- AI analyzes your question
- Routes to appropriate agents
- Returns intelligent responses
- Shows suggestion chips for common queries

### C. Route Exposure Screen (NEW!)
**What it does:** Calculate PM exposure on your route

**How to access:**
1. Go to the app router - you need to navigate to `/route-exposure`
2. Or add a navigation button (I can do this for you)

**What to try:**
1. Click "Calculate Exposure"
2. See exposure analysis (PM2.5, PM10)
3. View route score (0-100)
4. Read suggestions for optimization

### D. Prediction Screen (Already Exists)
**Enhanced with:**
- Better confidence scores
- More accurate predictions
- Time-of-day optimizations

**How to access:**
1. Click "Prediction" in navigation
2. View 24-hour forecast

### E. Habits Screen (Already Exists)
**Now connected to:**
- Memory Agent (saves your data)
- Advisory Agent (uses for recommendations)

## 3️⃣ Testing Backend Features

### A. Smart Purifier Control (Prototype)
**Note:** This is backend-only, no UI yet

**How to test:**
```dart
// In Dart DevTools console or create a test button:
final purifier = SmartPurifierAgent();
final result = await purifier.execute({
  'action': 'auto_adjust',
  'purifierId': 'living_room',
  'currentAqi': 120,
});
print(result);
```

### B. Background Notifications
**How to test:**
1. Enable notifications in your browser
2. Wait for periodic AQI checks (every hour)
3. You'll get notifications when AQI changes

### C. Memory System
**Automatic - test by:**
1. Using the chat screen multiple times
2. Your queries are saved (last 100)
3. Check Hive storage in browser DevTools

## 4️⃣ Verifying Agent Integration

### Check Agent Logs
Open browser console (F12) and look for:
```
💡 [DataFetchAgent] Fetching AQI...
💡 [AnalysisAgent] Analyzing data...
💡 [AdvisoryAgent] Generating recommendations...
```

### Test Each Agent

**Data Fetch Agent:**
- Automatically runs on home screen load
- Check console for API calls

**Analysis Agent:**
- Look at Insights Card on home screen
- Should show AI-generated analysis

**Advisory Agent:**
- Look at Recommendations Card
- Should show personalized advice

**Prediction Agent:**
- Go to Prediction screen
- Should show 24-hour forecast

**Simulation Agent:**
- Use chat: "What if traffic increases by 30%?"
- Should show scenario analysis

**Route Exposure Agent:**
- Navigate to `/route-exposure`
- Click "Calculate Exposure"

**Memory Agent:**
- Use chat multiple times
- Your history is saved automatically

**Orchestrator Agent:**
- Use chat with any question
- It routes to appropriate agents

## 5️⃣ Common Issues

### "No data showing"
- ✅ Check API keys are in `.env`
- ✅ Restart the app after adding keys
- ✅ Check browser console for errors

### "Chat not responding"
- ✅ Verify GEMINI_API_KEY is set
- ✅ Check internet connection
- ✅ Look for errors in console

### "Insights/Recommendations empty"
- ✅ Wait a few seconds for API calls
- ✅ Check WAQI_API_TOKEN is valid
- ✅ Refresh the page

### "Route exposure not visible"
- ✅ Navigate manually to `http://localhost:8080/route-exposure`
- ✅ Or I can add a button to navigation

## 6️⃣ Visual Checklist

When app is running with API keys, you should see:

**Home Screen:**
- [ ] AQI circle with current value
- [ ] Weather information
- [ ] **AI Insights Card** (new!)
- [ ] **Recommendations Card** (new!)
- [ ] 7-day forecast

**Navigation Bar:**
- [ ] Home icon
- [ ] Habits icon
- [ ] Prediction icon
- [ ] **Chat icon** (new!)

**Chat Screen:**
- [ ] Message input field
- [ ] Suggestion chips
- [ ] AI responses
- [ ] Message history

## 7️⃣ Quick Demo Flow

1. **Start:** Open `http://localhost:8080`
2. **Home:** See AI insights and recommendations
3. **Chat:** Click chat icon, ask "What's the AQI?"
4. **Prediction:** Click prediction, see 24-hour forecast
5. **Simulation:** In chat, ask "What if it rains?"
6. **Route:** Navigate to `/route-exposure`, calculate exposure

## 🎯 Want Me to Add Navigation Buttons?

I can add a button to easily access the Route Exposure screen. Should I:
1. Add it to the bottom navigation bar?
2. Add it to the sidebar?
3. Add it as a button on the home screen?

Let me know and I'll make it easily accessible!

## 📊 Expected Results

With API keys configured, you should see:
- **Real AQI data** from your location
- **AI-generated insights** about air quality
- **Personalized recommendations** based on conditions
- **Intelligent chat responses** from the orchestrator
- **24-hour predictions** with confidence scores
- **Route exposure calculations** with suggestions

---

**Need help?** Let me know which feature you want to test first and I'll guide you through it!
