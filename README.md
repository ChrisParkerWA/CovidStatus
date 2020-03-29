# CovidStatus
 App to display the status of COVID-19 globally and for each country.
 
 There are two selectable data sources:
 1. Microsoft/Bing (default at startup)
 2. South China Morning Post 
 
 In the Navigation Bar there is a data refresh button on the right and a Data Source Toggle on the left (switches between Data sources).
 
 This is a rudimentary App but I was prompted to have a crack at creating something that provided the COVID data the 
 way I wanted to see it after downloading the Open Source project by Julian Schiavo:
 https://github.com/julianschiavo/Covidcheck
 
 The App by Julian is very polished but desipite that it was rejected by Apple when he attempted to post it to the App Store.
 Apple have chosen to only allow COVID related Apps to be submitted by medical companies.  As a result of that, Julian
 decided to make it Open Source.
 
 27-Mar-2020
 Added a Sort option to allow sorting by country (ascending), cases (Descending), deaths (Descending) or recovered (Descending)
 
 29-Mar-2020
 Changed the image icon indicating those who are deceased. 
 Updated the DataModel to include the date that the data was lastUpdated which is now displayed.
 Added an Activity Indicator with UIView Wrapper code courtesy of an article by John Sundell.
https://www.swiftbysundell.com/tips/inline-wrapping-of-uikit-or-appkit-views-within-swiftui/
