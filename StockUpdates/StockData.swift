import SwiftUI
import Charts
struct StockData: View {
    @State private var searchStock = ""
    @State private var stockData : Stock?
    var stockArray : [(date:Date, price : Double)] {
        guard let stockData = stockData else {return []}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return stockData.timeSeriesDaily
            .sorted { $0.key > $1.key }
            .compactMap { dateStr, data in
                guard let date = dateFormatter.date(from: dateStr),
                      let closePrice = Double(data.the4Close) else {
                    return nil
                }
                return (date: date, price: closePrice)
            }
    }
    var body: some View {
        
            VStack{
                TextField("Enter stock", text: $searchStock)
                    .textFieldStyle(.roundedBorder)
                    .textCase(.uppercase)
                    .textInputAutocapitalization(.characters)
                    .padding()
                Button {
                    fetchData()
                }
                label: {
                    Text("Fetch")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .padding()
            VStack {
                if let stockData = stockData{
                    Text("Stock: \(stockData.metaData.the2Symbol)")
                        .font(.title3)
                    Text("Last refreshed: \(stockData.metaData.the3LastRefreshed)")
                    if let timeSeriesDaily = stockData.timeSeriesDaily.values.first {
                        Text("Opening price:$\(timeSeriesDaily.the1Open)")
                        Text("Closing price:$\(timeSeriesDaily.the4Close)")
                    }
                    }
                    if !stockArray.isEmpty {
                        VStack(alignment : .leading){
                            Chart(stockArray, id: \.date) { item  in
                                LineMark(x: .value("Date", item.date), y: .value("Price", item.price))
                                    
                            }
                            
                        }
                    
                }
            }
        }
    
    func fetchData(){
      
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchStock)&outputsize=compact&apikey=DZ43GS1LN5IOLBDP"
        guard let url = URL(string: urlString) else{
            return
        }
        URLSession.shared.dataTask(with: url) { data , response , error  in
            DispatchQueue.main.async {
                guard let data = data else{
                    return
                }
                do {
                    let stock = try JSONDecoder().decode(Stock.self, from: data)
                    self.stockData = stock
                    print("data decoded successfully")
                }
                catch{
                    print(error)
                }
            }
        }.resume()
    }
}

struct Stock: Codable {
    let metaData: MetaData
    let timeSeriesDaily: [String: TimeSeriesDaily]

    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeriesDaily = "Time Series (Daily)"
    }
}

// MARK: - MetaData
struct MetaData: Codable {
    let the1Information, the2Symbol, the3LastRefreshed, the4OutputSize: String
    let the5TimeZone: String

    enum CodingKeys: String, CodingKey {
        case the1Information = "1. Information"
        case the2Symbol = "2. Symbol"
        case the3LastRefreshed = "3. Last Refreshed"
        case the4OutputSize = "4. Output Size"
        case the5TimeZone = "5. Time Zone"
    }
}

// MARK: - TimeSeriesDaily
struct TimeSeriesDaily: Codable {
    let the1Open, the2High, the3Low, the4Close: String
    let the5Volume: String

    enum CodingKeys: String, CodingKey {
        case the1Open = "1. open"
        case the2High = "2. high"
        case the3Low = "3. low"
        case the4Close = "4. close"
        case the5Volume = "5. volume"
    }
}
#Preview {
    StockData()
}
