# CaloriScan

CaloriScan is a personal Flutter app that uses AI to detect food items from photos and instantly calculate their calorie and macro-nutrient content. Just point your camera at a meal, and the app identifies what's on your plate, estimates portion sizes, and breaks down protein, carbs, fat, and fiber — all in seconds.

## Features

- Take a photo or pick from gallery to analyze any meal
- AI identifies individual food items and estimates portions
- Edit portion sizes and remove incorrectly detected items
- View total calories with a visual ring indicator
- Full macro breakdown (protein, carbs, fat, fiber)
- Save meals and track your daily calorie history
- Swipe to delete past meals from history

## Tech Stack

- **Flutter** — cross-platform mobile UI
- **Claude API (Anthropic)** — AI image analysis and food detection
- **BLoC** — state management
- **Hive** — local meal history storage
- **Clean Architecture** — data / domain / presentation layers

## About

This is a personal project built to explore AI-driven image recognition in mobile apps. Food detection and nutrition analysis are powered by the **Claude Vision API** by Anthropic, which analyzes meal photos and returns structured nutrition data without needing a separate food database.

> Built with Claude API for image detection.


