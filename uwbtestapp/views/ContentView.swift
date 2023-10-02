import SwiftUI

var ble :BleRangingManager!

struct ContentView: View {
    @State var phonePositionX : Float
    @State var phonePositionY : Float
    @State var roomSideX : Float
    @State var roomSideY : Float
    @State var description = ""
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(){
                    NavigationLink(destination: UwbRangingView(roomSideX: self.roomSideX, roomSideY: self.roomSideY, realPositionX: self.phonePositionX, realPositionY: phonePositionY, testDescription: description)) {
                        Text("Go to UWB Ranging view")
                    }.frame(minHeight: 50)
                    NavigationLink(destination: BleRangingView(roomSideX: self.roomSideX, roomSideY: self.roomSideY, realPositionX: self.phonePositionX, realPositionY: phonePositionY, testDescription: description)) {
                        Text("Go to BLE Ranging view")
                    }.frame(minHeight: 50)
                    Spacer()
                    VStack {
                        Text("Wymiary pomieszczenia [m]").padding()
                        HStack{
                            Text("X:").padding()
                            TextField("0.0",
                                      value: $roomSideX,
                                      formatter: numberFormatter)
                            Text("Y:").padding()
                            TextField("0.0",
                                      value: $roomSideY,
                                      formatter: numberFormatter)
                        }.padding()
                    }
                    VStack {
                        Text("Realne położenie telefonu [m]").padding()
                        HStack{
                            Text("X:").padding()
                            TextField("0.0",
                                      value: $phonePositionX,
                                      formatter: numberFormatter)
                            Text("Y:").padding()
                            TextField("0.0",
                                      value: $phonePositionY,
                                      formatter: numberFormatter)
                        }.padding()
                    }
                    HStack {
                        Text("Opis badania").padding(.leading, 10)
                        TextField("Opis...", text: $description).padding(.trailing, 10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer()
                }
                .navigationTitle("Uwb ranging app")
            }
        }
    }
}

private let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.generatesDecimalNumbers = true
            return formatter
        }()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(phonePositionX: 0, phonePositionY: 0, roomSideX: 0, roomSideY: 0)
    }
}
