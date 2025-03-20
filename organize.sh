#!/bin/bash
# organize.sh - Reorganize the project files into the new folder structure.
# IMPORTANT: Ensure you have a backup or have committed your work before running this script.

# Create new directories according to the desired structure.
mkdir -p "CalorieHunter/App"
mkdir -p "CalorieHunter/CoreData"
mkdir -p "CalorieHunter/Models"
mkdir -p "CalorieHunter/Persistence"
mkdir -p "CalorieHunter/Managers/History"
mkdir -p "CalorieHunter/Managers/Other"
mkdir -p "CalorieHunter/Services"
mkdir -p "CalorieHunter/Utils/ChartHelper/ChartsOrganisers"
mkdir -p "CalorieHunter/Utils/Miscellaneous"
mkdir -p "CalorieHunter/Animation"
mkdir -p "CalorieHunter/ViewModels"
mkdir -p "CalorieHunter/Views/Home/AddFood"
mkdir -p "CalorieHunter/Views/Home/FoodList"
mkdir -p "CalorieHunter/Views/Home/Settings/UserProfile"
mkdir -p "CalorieHunter/Views/Charts/CalorieTracking"
mkdir -p "CalorieHunter/Views/Charts/BurnedCalories"
mkdir -p "CalorieHunter/Views/Charts/Food"
mkdir -p "CalorieHunter/Views/Charts/Steps"
mkdir -p "CalorieHunter/Views/Charts/Water"
mkdir -p "CalorieHunter/Views/Charts/Weight"
mkdir -p "CalorieHunter/Views/Onboarding"

# Move App-related files
mv Calorie_HunterApp.swift "CalorieHunter/App/"
mv Assets.xcassets "CalorieHunter/App/"
mv Info.plist "CalorieHunter/App/"
mv LaunchScreen.storyboard "CalorieHunter/App/"
mv "Calorie Hunter.entitlements" "CalorieHunter/App/"

# Move Core Data model
mv Calorie_Hunter.xcdatamodeld "CalorieHunter/CoreData/"

# Move Models (assumes Models folder exists in root)
if [ -d "Models" ]; then
  mv Models/*.swift "CalorieHunter/Models/"
fi

# Move Persistence file
if [ -f "Persistence.swift" ]; then
  mv Persistence.swift "CalorieHunter/Persistence/"
fi

# Move Managers
if [ -d "Managers" ]; then
  mv Managers/BurnedCaloriesHistoryManager.swift "CalorieHunter/Managers/History/"
  mv Managers/CalorieHistoryManager.swift "CalorieHunter/Managers/History/"
  mv Managers/StepsHistoryManager.swift "CalorieHunter/Managers/History/"
  mv Managers/WeightHistoryManager.swift "CalorieHunter/Managers/History/"
  mv Managers/KeyboardManager.swift "CalorieHunter/Managers/Other/"
fi

# Move Services
if [ -d "Services" ]; then
  mv Services/*.swift "CalorieHunter/Services/"
fi

# Move Utils
if [ -d "Utils/ChartHelper" ]; then
  mv Utils/ChartHelper/*.swift "CalorieHunter/Utils/ChartHelper/"
fi

if [ -d "Utils/ChartHelper/ChartsOrganisers" ]; then
  mv Utils/ChartHelper/ChartsOrganisers/*.swift "CalorieHunter/Utils/ChartHelper/ChartsOrganisers/"
fi

if [ -f "Utils/ExpandingButton.swift" ]; then
  mv Utils/ExpandingButton.swift "CalorieHunter/Utils/"
fi

if [ -f "Utils/ExpandingHapticButton.swift" ]; then
  mv Utils/ExpandingHapticButton.swift "CalorieHunter/Utils/"
fi

if [ -f "Utils/NavigationConfigurator.swift" ]; then
  mv Utils/NavigationConfigurator.swift "CalorieHunter/Utils/"
fi

if [ -f "Utils/Untitled.swift" ]; then
  mv Utils/Untitled.swift "CalorieHunter/Utils/Miscellaneous/"
fi

# Move Animation files
if [ -d "Animation" ]; then
  mv Animation/*.swift "CalorieHunter/Animation/"
  if [ -f "Animation/FireAnimation.html" ]; then
    mv Animation/FireAnimation.html "CalorieHunter/Animation/"
  fi
fi

# Move ViewModels
if [ -d "ViewModels" ]; then
  mv ViewModels/*.swift "CalorieHunter/ViewModels/"
fi

# Move Views
if [ -d "Views" ]; then
  # Top-level view files
  [ -f "Views/AnimeView.swift" ] && mv Views/AnimeView.swift "CalorieHunter/Views/"
  [ -f "Views/CalenderView.swift" ] && mv Views/CalenderView.swift "CalorieHunter/Views/"
  [ -f "Views/HomeView.swift" ] && mv Views/HomeView.swift "CalorieHunter/Views/"
  [ -f "Views/DayDetailView.swift" ] && mv Views/DayDetailView.swift "CalorieHunter/Views/"

  # Home subfolders
  if [ -d "Views/Home/AddFood" ]; then
    mv Views/Home/AddFood/*.swift "CalorieHunter/Views/Home/AddFood/"
  fi

  if [ -d "Views/Home/FoodList" ]; then
    mv Views/Home/FoodList/*.swift "CalorieHunter/Views/Home/FoodList/"
  fi

  if [ -d "Views/Home/Settings" ]; then
    mv Views/Home/Settings/*.swift "CalorieHunter/Views/Home/Settings/"
  fi

  # Onboarding: note the folder name may include spaces; adjust accordingly
  if [ -d "Views/Onboarding View" ]; then
    mv "Views/Onboarding View"/*.swift "CalorieHunter/Views/Onboarding/"
  fi

  # Charts – move all chart view files to a temporary Charts folder, then sort them into subfolders.
  if [ -d "Views/ChartsView" ]; then
    mkdir -p "CalorieHunter/Views/Charts"
    mv Views/ChartsView/*.swift "CalorieHunter/Views/Charts/"
    # Move files into subfolders based on filename patterns.
    mv CalorieHunter/Views/Charts/*Calorie*.swift "CalorieHunter/Views/Charts/CalorieTracking/" 2>/dev/null
    mv CalorieHunter/Views/Charts/*Burned*.swift "CalorieHunter/Views/Charts/BurnedCalories/" 2>/dev/null
    mv CalorieHunter/Views/Charts/*Food*.swift "CalorieHunter/Views/Charts/Food/" 2>/dev/null
    mv CalorieHunter/Views/Charts/*Steps*.swift "CalorieHunter/Views/Charts/Steps/" 2>/dev/null
    mv CalorieHunter/Views/Charts/*Water*.swift "CalorieHunter/Views/Charts/Water/" 2>/dev/null
    mv CalorieHunter/Views/Charts/*Weight*.swift "CalorieHunter/Views/Charts/Weight/" 2>/dev/null
  fi
fi

echo "Reorganization complete!"

