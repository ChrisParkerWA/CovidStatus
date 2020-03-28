//
//  ContentView.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var entries = [Country]()
    @State private var resultsArray = [Country]()
    @State private var totalCases = 0.0
    @State private var totalDeaths = 0.0
    @State private var totalRecovered = 0.0
    @State private var switchDataSource = false
    @State private var dataSourceText = "Microsoft/Bing"
    @State private var sortOptions = ["Country", "Cases", "Deaths", "Recovered"]
    @State private var selectedSortOption = "Country"
    
    var countrySectionHeader: some View { return
        HStack {
            Text("Status of Individual Countries")
            Spacer()
            Text("(\(entries.count))")
        }.padding([.top, .bottom], 7)
    }
    
    var sortedData: [Country] {
        let filtered = entries
        
        switch selectedSortOption {
        case "Country": return filtered.sorted { $0.country < $1.country }
        case "Cases": return filtered.sorted { $0.cases > $1.cases }
        case "Deaths": return filtered.sorted { $0.deaths > $1.deaths }
        default: return filtered.sorted { $0.recovered > $1.recovered }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Overall Status").padding([.top, .bottom], 7)) {
                        VStack(alignment: .leading) {
                            
                            //  Overall global cases, deaths and recoveries
                            HStack {
                                Image(self.cleanImageName(imageName: "globe"))
                                    .resizable()
                                    .background(Color.white)
                                    .frame(width: 60, height: 40)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1)
                                )
                                Text("Global Cases")
                                    .font(.system(size: 21, weight: .bold ))
                            }
                            
                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.red)
                                Text("\(totalCases, specifier: "%.0f")  ")
                                
                                Image("dead")
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                Text("\(totalDeaths, specifier: "%.0f")  ")
                                
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.green)
                                Text("\(totalRecovered, specifier: "%.0f")")
                            }
                            .font(.system(size: 18))
                        }
                    }
                    
                    Section(header: countrySectionHeader ) {
                       
                        ForEach(sortedData, id: \.self) { virusCase in
                            
                            //  Country cases, deaths and recoveries
                            VStack(alignment: .leading) {
                                Text(virusCase.country)
                                    .font(.system(size: 21, weight: .bold ))
                                HStack {
                                    Image(self.cleanImageName(imageName: virusCase.country))
                                        .resizable()
                                        .background(Color.white)
                                        .frame(width: 50, height: 33)
                                        .cornerRadius(5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5).stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                    Text(" ")
                                    Image(systemName: "thermometer")
                                        .foregroundColor(.red)
                                    
                                    Text("\(virusCase.cases, specifier: "%.0f")  ")
                                    
                                    Image("dead")
                                        .background(Color.black)
                                        .foregroundColor(.white).opacity(0.7)
                                    Text("\(virusCase.deaths, specifier: "%.0f")  ")
                                    
                                    Image(systemName: "heart.circle")
                                        .foregroundColor(.green)
                                    Text("\(virusCase.recovered, specifier: "%.0f")")
                                }
                                .font(.system(size: 18))
                            }
                            
                        }
                    }
                    
                    
                }
                //  Soting options
                HStack {
                    Text("Sort:")
                    Picker("", selection: $selectedSortOption) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }.padding(.horizontal)
                
                //  Developer credit and data source
                ZStack {
                    Color.gray
                        .frame(height: 25)
                    Text("Created by: Chris Parker | Data Source: \(dataSourceText)")
                        .font(.footnote)
                        .background(Color.gray)
                        .foregroundColor(.black)
                }
                
            }
            .navigationBarTitle("COVID-19 Cases")
            .navigationBarItems(leading:
                // Switch Data Source
                Button(action: {
                    self.switchDataSource.toggle()
                    self.loadData()
                }) {
                    Image(systemName: "arrow.right.arrow.left.circle")//arrow.swap
                        .font(.system(size: 25))
                        .padding(5)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
                ,trailing:
                Button(action: {
                    withAnimation {
                        self.loadData()
                    }
                    
                }) {
                    Image(systemName: "arrow.2.circlepath.circle")
                        .font(.system(size: 25))
                        .padding(5)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            )
        }
        .onAppear {
            withAnimation {
                self.loadData()
            }
        }
    }
    
    func loadData() {
        if switchDataSource {
            dataSourceText = "South China Morning Post"
            loadSCMPData()
        } else {
            dataSourceText = "Microsoft/Bing"
            loadBingData()
        }
    }
    
    func loadSCMPData() {
        entries.removeAll()
        resultsArray.removeAll()
        totalCases = 0
        totalDeaths = 0
        totalRecovered = 0
        
        let urlString = "https://interactive-static.scmp.com/sheet/wuhan/viruscases.json"
        DataManager().getJSON(urlString: urlString) { (results: CovidCases?) in
            if let results = results {
                for result in results.entries {
                    self.totalCases += Double(self.removeCommaFromNumbers(str: result.cases)) ?? 0.0
                    self.totalDeaths += Double(self.removeCommaFromNumbers(str: result.deaths)) ?? 0.0
                    self.totalRecovered += Double(self.removeCommaFromNumbers(str: result.recovered)) ?? 0.0
                    let newEntry = Country(country: result.country, cases: Double(self.removeCommaFromNumbers(str: result.cases)) ?? 0, deaths: Double(self.removeCommaFromNumbers(str: result.deaths)) ?? 0, recovered: Double(self.removeCommaFromNumbers(str: result.recovered)) ?? 0)
                    self.resultsArray.append(newEntry)
                }
                
                // Delay loading entries to give time for Totals to be populated in the UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.entries = self.resultsArray.sorted(by: { (lhs: Country, rhs: Country) -> Bool in
                        lhs.country < rhs.country
                    })
                    print(self.entries.count)
                }
            }
        }        
    }
    
    func loadBingData() {
        entries.removeAll()
        resultsArray.removeAll()
        totalCases = 0
        totalDeaths = 0
        totalRecovered = 0
        
        let urlString = "https://www.bing.com/covid/data"
        DataManager().getJSON(urlString: urlString) { (results: BingCases?) in
            if let results = results {
                for result in results.areas {                    
                    self.totalCases += Double(result.totalConfirmed)
                    self.totalDeaths += Double(result.totalDeaths ?? 0)
                    self.totalRecovered += Double(result.totalRecovered ?? 0)
                    let newEntry = Country(country: result.displayName, cases: Double(result.totalConfirmed), deaths: Double(result.totalDeaths ?? 0), recovered: Double(result.totalRecovered ?? 0))
                    self.resultsArray.append(newEntry)
                }
                
                // Delay loading entries to give time for Totals to be populated in the UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.entries = self.resultsArray.sorted(by: { (lhs: Country, rhs: Country) -> Bool in
                        lhs.country < rhs.country
                    })
                    print(self.entries.count)
                }
                
            }
        }
    }
    
    func cleanImageName(imageName: String) -> String {
        var str: String
        str = imageName
        str = removeAsterisk(str: str)
        str = removeTrailingSpace(str: str)
        str = removeDiatrics(str: str)
        str = removeSingleQuotes(str: str)
        #if DEBUG
        print(str)
        #endif
        return str
    }

    func removeAsterisk(str: String) -> String {
        return str.replacingOccurrences(of: "*", with: "")
    }
    
    func removeTrailingSpace(str: String) -> String {
        var newString: String
        newString = str
        while newString.last?.isWhitespace == true {
            newString = String(newString.dropLast())
        }
        return newString
    }
    
    func removeDiatrics(str: String) -> String {
        return str.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func removeSingleQuotes(str: String) -> String {
        var newString: String
        newString = str
        newString = newString.replacingOccurrences(of: "'", with: "'")
        newString = newString.replacingOccurrences(of: "’", with: "'")
        return newString
    }
    
    func removeCommaFromNumbers(str: String) -> String {
        return str.replacingOccurrences(of: ",", with: "")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\EnvironmentValues.colorScheme, ColorScheme.dark)
    }
}
