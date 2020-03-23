//
//  ContentView.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var entries = [CovidCases.Entry]()
    @State private var resultsArray = [CovidCases.Entry]()
    @State private var totalCases = 0.0
    @State private var totalDeaths = 0.0
    @State private var totalRecovered = 0.0
    @State private var switchDataSource = false
    @State private var dataSourceText = "Microsoft/Bing"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    VStack(alignment: .leading) {
                        
                        //  Overall global cases, deaths and recoveries
                        HStack {
                            Image(self.removeAsterisk(imageName: "globe"))
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
                    
                    
                    ForEach(entries, id: \.self) { virusCase in
                        
                        //  Country cases, deaths and recoveries
                        VStack(alignment: .leading) {
                            Text(virusCase.country)
                                .font(.system(size: 21, weight: .bold ))
                            HStack {
                                Image(self.removeAsterisk(imageName: virusCase.country))
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
                                
                                Text("\(virusCase.cases)  ")
                                
                                Image("dead")
                                    .background(Color.black)
                                    .foregroundColor(.white).opacity(0.7)
                                Text("\(virusCase.deaths)  ")
                                
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.green)
                                Text(virusCase.recovered)
                            }
                            .font(.system(size: 18))
                        }
                        
                    }
                    
                    
                }
                //  Developer credit and data source
                ZStack {
                    Color.gray
                        .frame(height: 35)
                    Text("Created by: Chris Parker\nData Source: \(dataSourceText)")
                        .font(.footnote)
                        .background(Color.gray)
                        .foregroundColor(.black)
                }
                
            }
            .navigationBarTitle("COVID-19 Cases")
            .navigationBarItems(leading:
                Button(action: {
                    self.switchDataSource.toggle()
                    self.loadData()
                }) {
                    Image(systemName: "arrow.right.arrow.left.circle")//arrow.swap
                        .font(.system(size: 25))
                        .padding(10)
                        .background(Color.clear)
                        .clipShape(Circle())
                },trailing:
                Button(action: {
                    withAnimation {
                        self.loadData()
                    }
                    
                }) {
                    Image(systemName: "arrow.2.circlepath.circle")
                        .font(.system(size: 25))
                        .padding(10)
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
                    self.totalCases += Double(self.removeCommaFromNumbers(str: result.cases)) ?? 0
                    self.totalDeaths += Double(self.removeCommaFromNumbers(str: result.deaths)) ?? 0
                    self.totalRecovered += Double(self.removeCommaFromNumbers(str: result.recovered)) ?? 0
                    self.resultsArray.append(result)
                }
                
                // Delay loading entries to give time for Totals to be populated in the UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.entries = self.resultsArray.sorted(by: { (lhs: CovidCases.Entry, rhs: CovidCases.Entry) -> Bool in
                        lhs.country < rhs.country
                    })
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
                    self.totalDeaths += Double(result.totalDeaths)
                    self.totalRecovered += Double(result.totalRecovered)
                    let newEntry = CovidCases.Entry(country: result.displayName, cases: String(result.totalConfirmed), deaths: String(result.totalDeaths), recovered: String(result.totalRecovered), lastupdated: "", comments: "")
                    self.resultsArray.append(newEntry)
                }
                
                // Delay loading entries to give time for Totals to be populated in the UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.entries = self.resultsArray.sorted(by: { (lhs: CovidCases.Entry, rhs: CovidCases.Entry) -> Bool in
                        lhs.country < rhs.country
                    })
                }
                
            }
        }
    }

    
    func removeAsterisk(imageName: String) -> String {
//        print("(\(imageName))")
        var str: String
        str = imageName
        str = removeTrailingSpace(str: str)
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
