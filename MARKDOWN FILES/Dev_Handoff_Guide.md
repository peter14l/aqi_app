# Developer Handoff Guide -- Personal AQI Tracker

## 1. Project Overview

This handoff guide is intended for supplying to an AI editor or
development assistant who will modify and complete the current Personal
AQI Tracker project. It consolidates all requirements, architecture,
agent responsibilities, evaluation criteria, and workflow expectations.

The project is an AI‑powered multi‑agent system designed to: - Interpret
user schedules and environmental data\
- Reason about real‑time AQI and weather\
- Coordinate multiple tools and APIs\
- Provide personalized health and exposure insights\
- Maintain long‑term user habits\
- Control smart air purifiers (prototype stage)\
- Act as a "personal air‑quality concierge"

------------------------------------------------------------------------

## 2. Core Concept

A multi‑agent intelligent system that: - Predicts AQI\
- Explains environmental causes\
- Generates actionable and personalized recommendations\
- Performs simulations\
- Uses real‑time and historical data\
- Integrates with LLM reasoning\
- Interacts with the user conversationally\
- Can scale with additional tool integrations

------------------------------------------------------------------------

## 3. Team Responsibilities

### **Samprit -- API & Data Fetch Engineering**

**Tasks** 1. Pull real‑time AQI data across India\
2. Pull weather data (temperature, humidity, PM2.5, PM10)\
3. Fetch historical AQI\
4. Fetch location + route‑based user commute data\
- Used to estimate daily PM exposure\
5. Implement agent tools: - `realtime_aqi(location)` -
`realtime_weather(location)` - `history_aqi(location, dateRange)` -
Optional: `predict_aqi(location, time)` via ML model\
6. Fallback to Google search when necessary

------------------------------------------------------------------------

### **Me -- Analysis, Advisory & Orchestration**

**Agents** 1. **Analysis Agent (Sequential)**\
- Interprets fetched data\
- Uses prediction outputs\
- Performs reasoning with Gemini/LLM

2.  **Advisory Agent (Parallel)**
    -   Forecasts risk\
    -   Generates recommendations\
    -   Suggests actions based on habits (daily commute, routines)
3.  **Simulation Agent**
    -   Runs hypothetical scenarios\
    -   Uses `history_aqi` + `predict_aqi`\
    -   Generates future‑state environment projections
4.  **Orchestrator Agent**
    -   Routes queries to the correct agents\
    -   Manages task loops\
    -   Ensures clean sequencing and parallel execution

------------------------------------------------------------------------

### **Soham -- Backend, Memory & Infrastructure**

**Tasks** 1. Organize API response data for consumption by Fetch Agent\
2. Implement Memory Agent\
- Store long‑term preferences (city, age, health, daily routes)\
- Use Memory Bank + InMemorySessionService\
3. Background scheduling\
- Push alerts even when app is inactive\
4. Logging & Monitoring\
- Agent calls\
- Tool usage\
- Errors\
- API failures

------------------------------------------------------------------------

## 4. System Architecture

### **Agents Required**

-   Data Fetch Agent\
-   Prediction Agent\
-   Analysis Agent\
-   Advisory Agent\
-   Simulation Agent\
-   Route Exposure Agent\
-   Memory Agent\
-   Orchestrator Agent

### **Core Features**

-   Real‑time AQI + weather ingestion\
-   Historical AQI patterns (monthly averages, peaks, lows)\
-   User‑route exposure computation\
-   AQI prediction model\
-   Personalized advisory system\
-   Real‑time interaction loop\
-   Smart‑purifier control (optional prototype)

------------------------------------------------------------------------

## 5. Agent Definitions & Tools

### **Base Tools**

  -------------------------------------------------------------------------------------
  Tool                                 Description
  ------------------------------------ ------------------------------------------------
  `realtime_aqi(location)`             Returns int AQI

  `realtime_weather(location)`         Returns (temperature, descriptor list)

  `history_aqi(location, dateRange)`   Returns nested lists for avg/peak/least AQI

  `predict_aqi(location, time)`        Optional ML‑based prediction tool
  -------------------------------------------------------------------------------------

------------------------------------------------------------------------

## 6. Evaluation Framework (For AI Editor & QA)

### **1. Agent‑Level Evaluation**

#### **1.1 Data Fetch Agent**

-   API uptime\
-   Response time\
-   Accuracy vs ground‑truth datasets\
-   Handling missing/corrupted data

Automated tests: - Cron job simulating 500 errors, throttling, empty
JSON

------------------------------------------------------------------------

#### **1.2 Prediction Agent**

-   RMSE / MAE vs actual AQI\
-   Stability\
-   Time‑of‑day performance\
-   Adaptability with new data

Testing: - Backtest: train on 30 days → predict 7 days → compute error

------------------------------------------------------------------------

#### **1.3 Route Exposure Agent**

Measures: - Path scoring consistency\
- Latency (1--20 routes)\
- Correct AQI→segment mapping\
- Exposure accuracy

Tests: - 100 synthetic routes\
- Compare to manually‑calculated ground truths

------------------------------------------------------------------------

#### **1.4 Simulation Agent**

Measures: - Correct "what‑if" scenarios\
- Output stability\
- Time to generate complex simulations

Tests: - Predefined scenario inputs with expected outputs

------------------------------------------------------------------------

### **2. Multi‑Agent Workflow Evaluation**

Measures: - Latency request → final advice\
- Failure recovery\
- Sequencing correctness\
- Parallel agent consistency\
- Tool call correctness

------------------------------------------------------------------------

### **3. Long‑Term Memory Evaluation**

Measures: - Accuracy of past route/behavior retrieval\
- Latency\
- Memory corruption avoidance\
- Scaling behavior

------------------------------------------------------------------------

### **4. Safety & Reliability Evaluation**

-   No hallucinated AQI values\
-   No unsafe health advice\
-   Proper error responses during missing data\
-   Noise injection tests\
-   Red‑team prompt validation

------------------------------------------------------------------------

## 7. Notes for Editor / AI Developer

-   Maintain modular, agent‑based architecture\
-   Use structured tool schemas\
-   Add robust fallback logic for all API failures\
-   Ensure long‑term memory is efficient and safe\
-   Prioritize clean orchestration logic and error‑handling\
-   Ensure agents are testable independently

------------------------------------------------------------------------
