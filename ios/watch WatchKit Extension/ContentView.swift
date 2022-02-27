//
//  ContentView.swift
//  watch WatchKit Extension
//
//  Created by Mostafa Ibrahim on 27/02/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: WatchViewModel = WatchViewModel()
    
    var body: some View {
        VStack {
            Text("Counter: \(viewModel.counter)")
                .padding()
            Button(action: {
                viewModel.incrementCounter()
            }) {
                Text("+ by 2")
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
