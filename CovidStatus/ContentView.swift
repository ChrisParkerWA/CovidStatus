//
//  ContentView.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var entries = [Country]()
    @State private var resultsArray = [Country]()
    @State private var lastUdated = ""
    @State private var totalCases = 0.0
    @State private var totalDeaths = 0.0
    @State private var totalRecovered = 0.0
    @State private var switchDataSource = false
    @State private var dataSourceText = "Microsoft/Bing"
    @State private var sortOptions = ["Country", "Cases", "Deaths", "Recovered"]
    @State private var selectedSortOption = "Country"
    @State private var showActivityIndicator = false
    
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
            ZStack {
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
                                            RoundedRectangle(cornerRadius: 5).stroke((colorScheme == .dark ? Color.white : Color.black).opacity(0.5), lineWidth: 1)
                                    )
                                    
                                    VStack(alignment: .leading) {
                                        Text("Global Cases")
                                            .font(.system(size: 21, weight: .bold ))
                                        Text("Last updated: \(formatDate(dateString: lastUdated)) UTC")
                                            .font(.system(size: 12, weight: .bold ))
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "thermometer")
                                        .foregroundColor(.red)
                                    Text("\(totalCases, specifier: "%.0f")  ")
                                    
                                    Image("dead")
                                        .resizable()
                                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
                                        .frame(width: 25, height: 25)

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
                                                RoundedRectangle(cornerRadius: 5).stroke((self.colorScheme == .dark ? Color.white : Color.black).opacity(0.5), lineWidth: 1)
                                        )
                                        
                                        Image(systemName: "thermometer")
                                            .foregroundColor(.red)
                                        
                                        Text("\(virusCase.cases, specifier: "%.0f")  ")
                                        
                                        Image("dead")
                                            .resizable()
                                            .foregroundColor(self.colorScheme == .dark ? .white : .black)
                                            .frame(width: 25, height: 25)
                    
                                        Text("\(virusCase.deaths, specifier: "%.0f")  ")
                                        
                                        Image(systemName: "heart.circle")
                                            .foregroundColor(.green)
                                        Text("\(virusCase.recovered, specifier: "%.0f")")
                                    }
                                    .font(.system(size: 17))
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
                    }
                    .padding(.horizontal)
                    
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
                
                //  Display Activity Indicator while loading data.
                Wrap(UIActivityIndicatorView()) {
                    if self.showActivityIndicator {
                        $0.startAnimating()
                    } else {
                        $0.stopAnimating()
                    }
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
        showActivityIndicator = true
        if switchDataSource {
            dataSourceText = "SCMP"
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
        DataManager().getJSON(urlString: urlString) { (results: SCMPCases?) in
            if let results = results {
                self.lastUdated = results.last_updated
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
                    self.showActivityIndicator = false
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
                self.lastUdated = results.lastUpdated
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
                    self.showActivityIndicator = false
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
        str = removeForwardeQuotes(str: str)
        #if DEBUG
        print(str)
        #endif
        if UIImage(named: str) == nil {
            str = "FlagMissing"
            #if DEBUG
            print(">>>>>>\(imageName) FLAG MISSING")
            #endif
        }       
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
    
    func removeForwardeQuotes(str: String) -> String {
        return str.replacingOccurrences(of: "’", with: "'")
    }
    
    func removeCommaFromNumbers(str: String) -> String {
        return str.replacingOccurrences(of: ",", with: "")
    }
    
    func formatDate(dateString: String) -> String {
        guard dateString != "" else { return "Date is nil"}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"  //  2020-03-29T00:50:02.918Z
        let dateObj = formatter.date(from: dateString)
        formatter.dateFormat = "dd-MMM-yyy HH:mm:ss"
        
        return formatter.string(from: dateObj!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\EnvironmentValues.colorScheme, ColorScheme.dark)
    }
}
