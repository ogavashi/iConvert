//
//  ContentView.swift
//  iConvert
//
//  Created by Oleg Gavashi on 13.07.2023.
//

import SwiftUI

protocol UnitConvertible {
    var dimension: Dimension { get }
}

extension UnitLength: UnitConvertible {
    var dimension: Dimension { return self }
}

extension UnitMass: UnitConvertible {
    var dimension: Dimension { return self }
}

struct UnitConverter {
    static let lengthUnits: [String: UnitConvertible] = [
        "cm": UnitLength.centimeters,
        "m": UnitLength.meters,
        "dm": UnitLength.decimeters,
        "km": UnitLength.kilometers
    ]
    
    static let massUnits: [String: UnitConvertible] = [
        "g": UnitMass.grams,
        "kg": UnitMass.kilograms,
        "lb": UnitMass.pounds
    ]
    
    static let units: [String: [String: UnitConvertible]] = [
        "Distance": lengthUnits,
        "Mass": massUnits
    ]
    
    static let defaultUnits: [String: (input: String, output: String)] = [
        "Distance": (input: "km", output: "m"),
        "Mass": (input: "kg", output: "lb")
    ]

    
    static func calcConverted(value: Double, type: String, from: String, to: String) -> Double {
        guard let fromUnit = units[type]?[from],
              let toUnit = units[type]?[to] else {
            fatalError("Invalid units provided")
        }
        
        let fromValue = Measurement(value: value, unit: fromUnit.dimension)
        
        return fromValue.converted(to: toUnit.dimension).value
    }
}


struct ContentView: View {
    
    @State private var inputValue = 0.0
    @State private var inputUnits = "km"
    @State private var outputValue = 0.0
    @State private var outputUnits = "m"
    @State private var unitsCategory = "Distance"
    
    @FocusState private var isFocused: Bool
    
    var selectedUnits: [String: UnitConvertible]?  {
        UnitConverter.units[unitsCategory]
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Input value", value: $inputValue, format: .number)
                        .onChange(of: inputValue) { _ in
                            outputValue = UnitConverter.calcConverted(value: inputValue, type: unitsCategory, from: inputUnits, to: outputUnits)
                        }
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                    
                    Picker("Input units", selection: $inputUnits ) {
                        ForEach(Array(selectedUnits!.keys), id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: inputUnits) {_ in
                        outputValue = UnitConverter.calcConverted(value: inputValue, type: unitsCategory, from: inputUnits, to: outputUnits)
                    }
                    
                } header: {
                    Text("Input value")
                }
                
                Section {
                    TextField("Input value", value: $outputValue, format: .number)
                        .onChange(of: outputValue) { _ in
                            inputValue = UnitConverter.calcConverted(value: outputValue, type: unitsCategory, from: outputUnits, to: inputUnits)
                        }
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                    
                    Picker("Input units", selection: $outputUnits ) {
                        ForEach(Array(selectedUnits!.keys), id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: outputUnits) {_ in
                        outputValue = UnitConverter.calcConverted(value: inputValue, type: unitsCategory, from: inputUnits, to: outputUnits)
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("Converted value")
                }
                
                Section {
                    Picker("Units category", selection: $unitsCategory) {
                        ForEach(Array(UnitConverter.units.keys), id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: unitsCategory) { _ in
                        guard let units = UnitConverter.defaultUnits[unitsCategory] else {
                            fatalError("Invalid units category")
                        }
                        inputUnits = units.input
                        outputUnits = units.output
                    }
                }
            }
            .navigationTitle("iConvert")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
